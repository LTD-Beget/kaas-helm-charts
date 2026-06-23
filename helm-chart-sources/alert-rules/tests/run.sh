#!/usr/bin/env bash
#
# Renders the ENTIRE alert-rules chart (every group of every rule file) into a
# temp dir and runs every *_test.yaml in this directory against it with
# vmalert-tool. Nothing is written into the repo — the rendered rules are a
# transient artifact for the duration of the run.
#
# vmalert-tool (not promtool) is used on purpose: the chart runs on
# VictoriaMetrics/vmalert, and MetricsQL staleness / last_over_time semantics
# differ from Prometheus. Tests must run on the same engine as prod.
#
# No rule/group/file names are hardcoded: all rules are force-enabled generically
# from files/defaults/*.yaml, so a test for any rule (in any file, present or
# future) works without touching this script.
#
# Adding a new test = drop a new <something>_test.yaml here; no script changes.
#
# Requires: helm, yq, vmalert-tool. If vmalert-tool is not on PATH, falls back to
# ~/.local/bin/vmalert-tool, then to the victoriametrics/vmalert-tool container
# when docker is available. Install vmalert-tool from the vmutils release:
#   https://github.com/VictoriaMetrics/VictoriaMetrics/releases (asset vmutils-*)
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

# Resolve vmalert-tool: PATH, then ~/.local/bin, then the docker image.
VMALERT_TOOL=""
if command -v vmalert-tool >/dev/null 2>&1; then
  VMALERT_TOOL="vmalert-tool"
elif [ -x "${HOME}/.local/bin/vmalert-tool" ]; then
  VMALERT_TOOL="${HOME}/.local/bin/vmalert-tool"
fi

# --disableAlertgroupLabel: don't require `groupname` in alert_rule_test and don't
# inject the group name as a label — alerts are matched by alertname only, and our
# rendered group names are auto-prefixed (release/VMRule) and not meant to be
# referenced from tests.
run_unittest() {
  if [ -n "${VMALERT_TOOL}" ]; then
    "${VMALERT_TOOL}" unittest --disableAlertgroupLabel --files="$1"
  elif command -v docker >/dev/null 2>&1; then
    docker run --rm -v "${WORK}:/work" -w /work \
      victoriametrics/vmalert-tool:latest unittest --disableAlertgroupLabel --files="$1"
  else
    echo "ERROR: vmalert-tool not found and docker is unavailable." >&2
    echo "Install it from the vmutils release:" >&2
    echo "  https://github.com/VictoriaMetrics/VictoriaMetrics/releases" >&2
    exit 1
  fi
}

# Run each test file separately so the output shows which file ran and its result.
RC=0
for f in "${BASENAMES[@]}"; do
  echo ">> ${f}"
  run_unittest "${f}" || RC=1
done

exit "${RC}"
