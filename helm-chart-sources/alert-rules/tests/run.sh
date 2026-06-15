#!/usr/bin/env bash
#
# Renders the ENTIRE alert-rules chart (every group of every rule file) into a
# temp dir and runs every *_test.yaml in this directory against it. Nothing is
# written into the repo — the rendered rules are a transient artifact for the
# duration of the run.
#
# No rule/group/file names are hardcoded: all rules are force-enabled generically
# from files/defaults/*.yaml, so a test for any rule (in any file, present or
# future) works without touching this script.
#
# Adding a new test = drop a new <something>_test.yaml here; no script changes.
#
# Requires: helm, yq, promtool (Prometheus). If promtool is not on PATH, falls
# back to the prom/prometheus container image when docker is available.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

shopt -s nullglob
TEST_FILES=("${SCRIPT_DIR}"/*_test.yaml)
if [ ${#TEST_FILES[@]} -eq 0 ]; then
  echo "No *_test.yaml files found in ${SCRIPT_DIR}" >&2
  exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

echo ">> Building enable-all values from files/defaults"
# Deep-merge every rule file, then flip every `enabled` flag to true so the whole
# chart renders regardless of the per-rule defaults.
yq ea '. as $item ireduce ({}; . * $item)' "${CHART_DIR}"/files/defaults/*.yaml \
  | yq '(.. | select(tag == "!!map" and has("enabled")).enabled) = true | {"vmrules": .}' \
  > "${WORK}/values.enable-all.yaml"

echo ">> Rendering all rules from chart"
# Collect spec.groups from every rendered VMRule into one rules file. Group names
# are prefixed with the VMRule name to keep them unique across the chart.
helm template t "${CHART_DIR}" -f "${WORK}/values.enable-all.yaml" \
  --show-only templates/vmrules.yaml \
  | yq ea '[ .metadata.name as $n | (.spec.groups // [])[] | {"name": ($n + "/" + .name), "rules": .rules} ] | {"groups": .}' \
  > "${WORK}/rendered.rules.yaml"

BASENAMES=()
for f in "${TEST_FILES[@]}"; do
  cp "${f}" "${WORK}/"
  BASENAMES+=("$(basename "${f}")")
done

cd "${WORK}"
echo ">> Running promtool on: ${BASENAMES[*]}"
if command -v promtool >/dev/null 2>&1; then
  exec promtool test rules "${BASENAMES[@]}"
elif command -v docker >/dev/null 2>&1; then
  echo ">> promtool not found; running via prom/prometheus container"
  exec docker run --rm -v "${WORK}:/work" -w /work \
    --entrypoint promtool prom/prometheus:latest test rules "${BASENAMES[@]}"
else
  echo "ERROR: neither promtool nor docker is available." >&2
  echo "Install Prometheus (brew install prometheus) or Docker, then re-run." >&2
  exit 1
fi
