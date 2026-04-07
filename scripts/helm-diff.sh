#!/usr/bin/env bash
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CERT_FILTER="admin-password\|ca.crt\|tls.crt\|tls.key\|ca.key\|checksum/secret\|caBundle"

# Colors
if [[ -t 1 ]]; then
  C_RESET="\033[0m"
  C_BOLD="\033[1m"
  C_DIM="\033[2m"
  C_GREEN="\033[32m"
  C_RED="\033[31m"
  C_YELLOW="\033[33m"
  C_CYAN="\033[36m"
  C_BLUE="\033[34m"
  C_MAGENTA="\033[35m"
  C_BG_RED="\033[41m"
  C_BG_GREEN="\033[42m"
  C_BG_YELLOW="\033[43m"
else
  C_RESET="" C_BOLD="" C_DIM="" C_GREEN="" C_RED="" C_YELLOW=""
  C_CYAN="" C_BLUE="" C_MAGENTA="" C_BG_RED="" C_BG_GREEN="" C_BG_YELLOW=""
fi

usage() {
  cat <<EOF
${C_BOLD}Usage:${C_RESET} $(basename "$0") [OPTIONS]

Compare helm template output between two git refs for all charts.

${C_BOLD}Options:${C_RESET}
  -b, --base REF       Base git ref or "workdir" (default: origin/<current-branch>)
  -t, --target REF     Target git ref or "workdir" (default: workdir)
  -c, --chart NAME     Only check a specific chart (can be repeated)
  -v, --verbose        Show diff details for non-identical charts
  -h, --help           Show this help

${C_BOLD}Examples:${C_RESET}
  $(basename "$0")                                    # workdir vs origin/current-branch
  $(basename "$0") -b main                            # workdir vs main
  $(basename "$0") -b HEAD~1 -t HEAD                  # previous commit vs current commit
  $(basename "$0") -b workdir -t HEAD                 # current files vs last commit
  $(basename "$0") -b origin/main -c addonset -v      # specific chart, verbose
EOF
  exit 0
}

BASE_REF=""
TARGET_REF="workdir"
CHARTS=()
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--base)    BASE_REF="$2"; shift 2 ;;
    -t|--target)  TARGET_REF="$2"; shift 2 ;;
    -c|--chart)   CHARTS+=("$2"); shift 2 ;;
    -v|--verbose) VERBOSE=true; shift ;;
    -h|--help)    usage ;;
    *)            echo "Unknown option: $1"; usage ;;
  esac
done

CURRENT_BRANCH=$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || echo "")
if [[ -z "$BASE_REF" ]]; then
  if [[ -n "$CURRENT_BRANCH" ]]; then
    BASE_REF="origin/$CURRENT_BRANCH"
  else
    printf "${C_RED}Error: not on a branch, specify --base explicitly${C_RESET}\n" >&2
    exit 1
  fi
fi

if [[ ${#CHARTS[@]} -eq 0 ]]; then
  mapfile -t CHARTS < <(ls -d "$REPO_ROOT"/helm-chart-sources/*/Chart.yaml 2>/dev/null \
    | sed "s|$REPO_ROOT/helm-chart-sources/||;s|/Chart.yaml||" | sort)
fi

WORK_DIR=$(mktemp -d "/tmp/helm-diff.XXXXXX")
trap 'rm -rf "$WORK_DIR"' EXIT

BASE_DIR="$WORK_DIR/base"
TARGET_DIR="$WORK_DIR/target"

setup_ref() {
  local ref=$1 dest=$2
  if [[ "$ref" == "workdir" ]]; then
    echo "$REPO_ROOT/helm-chart-sources" > "$dest.path"
    return
  fi
  git -C "$REPO_ROOT" worktree add -q --detach "$dest" "$ref" 2>/dev/null
  echo "$dest/helm-chart-sources" > "$dest.path"
  for chart_dir in "$REPO_ROOT"/helm-chart-sources/*/charts; do
    [[ -d "$chart_dir" ]] || continue
    local chart_name
    chart_name=$(basename "$(dirname "$chart_dir")")
    local wt_chart="$dest/helm-chart-sources/$chart_name"
    if [[ -d "$wt_chart" ]]; then
      rm -rf "$wt_chart/charts" 2>/dev/null
      cp -a "$chart_dir" "$wt_chart/charts"
      for tgz in "$wt_chart/charts"/*.tgz; do
        [[ -f "$tgz" ]] && tar xzf "$tgz" -C "$wt_chart/charts" 2>/dev/null
      done
    fi
  done
}

cleanup_ref() {
  local dest=$1
  if [[ -d "$dest" && -f "$dest/.git" ]]; then
    git -C "$REPO_ROOT" worktree remove --force "$dest" 2>/dev/null || true
  fi
}

print_separator() {
  printf "${C_DIM}%s${C_RESET}\n" "$(printf '%.0s─' {1..70})"
}

printf "\n${C_DIM}Preparing...${C_RESET}\n"
printf "  base:   ${C_CYAN}%s${C_RESET}" "$BASE_REF"
setup_ref "$BASE_REF" "$BASE_DIR"
printf " ${C_GREEN}ok${C_RESET}\n"
printf "  target: ${C_CYAN}%s${C_RESET}" "$TARGET_REF"
setup_ref "$TARGET_REF" "$TARGET_DIR"
printf " ${C_GREEN}ok${C_RESET}\n\n"

base_charts_root=$(cat "$BASE_DIR.path")
target_charts_root=$(cat "$TARGET_DIR.path")

print_separator
printf "${C_BOLD}  HELM TEMPLATE DIFF${C_RESET}  ${C_CYAN}%s${C_RESET} ${C_DIM}vs${C_RESET} ${C_CYAN}%s${C_RESET}\n" "$BASE_REF" "$TARGET_REF"
print_separator
printf "\n"

OK=0; CERTONLY=0; BOTHFAIL=0; DIFF_CNT=0; MISMATCH=0
DIFF_CHARTS=()

max_name_len=0
for chart in "${CHARTS[@]}"; do
  (( ${#chart} > max_name_len )) && max_name_len=${#chart}
done

for chart in "${CHARTS[@]}"; do
  base_chart="$base_charts_root/$chart"
  target_chart="$target_charts_root/$chart"

  b_out="$WORK_DIR/b_$chart.yaml"; b_err="$WORK_DIR/b_$chart.err"
  t_out="$WORK_DIR/t_$chart.yaml"; t_err="$WORK_DIR/t_$chart.err"

  B_OK=true; T_OK=true
  helm template test "$base_chart"   > "$b_out" 2>"$b_err" || B_OK=false
  helm template test "$target_chart" > "$t_out" 2>"$t_err" || T_OK=false

  padded=$(printf "%-${max_name_len}s" "$chart")

  if ! $B_OK && ! $T_OK; then
    if diff -q "$b_err" "$t_err" >/dev/null 2>&1; then
      printf "  ${C_DIM}%s${C_RESET}  ${C_YELLOW}SKIP${C_RESET} ${C_DIM}(both fail, same error)${C_RESET}\n" "$padded"
      BOTHFAIL=$((BOTHFAIL+1))
    else
      printf "  ${C_BOLD}%s${C_RESET}  ${C_BG_RED}${C_BOLD} FAIL ${C_RESET} ${C_RED}both fail, different errors${C_RESET}\n" "$padded"
      DIFF_CHARTS+=("$chart")
      if $VERBOSE; then
        diff "$b_err" "$t_err" | head -5 | while IFS= read -r line; do
          printf "    ${C_DIM}%s${C_RESET}\n" "$line"
        done
      fi
      DIFF_CNT=$((DIFF_CNT+1))
    fi
  elif $B_OK && $T_OK; then
    DIFF=$(diff "$b_out" "$t_out" || true)
    if [[ -z "$DIFF" ]]; then
      printf "  ${C_DIM}%s${C_RESET}  ${C_GREEN}OK${C_RESET}\n" "$padded"
      OK=$((OK+1))
    else
      NON_CERT=$(echo "$DIFF" | grep "^[<>]" | grep -v "$CERT_FILTER" | wc -l)
      TOTAL=$(echo "$DIFF" | grep "^[<>]" | wc -l)
      if [[ "$NON_CERT" -eq 0 ]]; then
        printf "  ${C_DIM}%s${C_RESET}  ${C_GREEN}OK${C_RESET} ${C_DIM}(random certs/keys, %d lines)${C_RESET}\n" "$padded" "$TOTAL"
        CERTONLY=$((CERTONLY+1))
      else
        CERT_LINES=$((TOTAL - NON_CERT))
        CERT_NOTE=""
        [[ $CERT_LINES -gt 0 ]] && CERT_NOTE=" ${C_DIM}+ ${CERT_LINES} cert${C_RESET}"
        printf "  ${C_BOLD}%s${C_RESET}  ${C_RED}DIFF${C_RESET} ${C_YELLOW}%d changed lines${C_RESET}%b\n" "$padded" "$NON_CERT" "$CERT_NOTE"
        DIFF_CHARTS+=("$chart")
        if $VERBOSE; then
          printf "\n"
          echo "$DIFF" | grep "^[<>]" | grep -v "$CERT_FILTER" | head -20 | while IFS= read -r line; do
            if [[ "$line" == "<"* ]]; then
              printf "    ${C_RED}%s${C_RESET}\n" "$line"
            else
              printf "    ${C_GREEN}%s${C_RESET}\n" "$line"
            fi
          done
          [[ $NON_CERT -gt 20 ]] && printf "    ${C_DIM}... and %d more lines${C_RESET}\n" "$((NON_CERT - 20))"
          printf "\n"
        fi
        DIFF_CNT=$((DIFF_CNT+1))
      fi
    fi
  else
    printf "  ${C_BOLD}%s${C_RESET}  ${C_BG_RED}${C_BOLD} ERR ${C_RESET}" "$padded"
    if ! $B_OK; then printf " ${C_RED}base fails:${C_RESET} ${C_DIM}%s${C_RESET}" "$(tail -1 "$b_err")"; fi
    if ! $T_OK; then printf " ${C_RED}target fails:${C_RESET} ${C_DIM}%s${C_RESET}" "$(tail -1 "$t_err")"; fi
    printf "\n"
    MISMATCH=$((MISMATCH+1))
  fi
done

TOTAL_CHARTS=${#CHARTS[@]}
PASS=$((OK + CERTONLY))

printf "\n"
print_separator

if [[ $DIFF_CNT -eq 0 && $MISMATCH -eq 0 ]]; then
  printf "  ${C_BG_GREEN}${C_BOLD} PASS ${C_RESET} "
else
  printf "  ${C_BG_RED}${C_BOLD} FAIL ${C_RESET} "
fi

printf "${C_GREEN}%d identical${C_RESET}" "$OK"
[[ $CERTONLY -gt 0 ]] && printf " ${C_DIM}+ %d certs-only${C_RESET}" "$CERTONLY"
[[ $DIFF_CNT -gt 0 ]] && printf "  ${C_RED}%d with diff${C_RESET}" "$DIFF_CNT"
[[ $MISMATCH -gt 0 ]] && printf "  ${C_RED}%d errors${C_RESET}" "$MISMATCH"
[[ $BOTHFAIL -gt 0 ]] && printf "  ${C_YELLOW}%d skipped${C_RESET}" "$BOTHFAIL"
printf "  ${C_DIM}(%d total)${C_RESET}\n" "$TOTAL_CHARTS"

if [[ ${#DIFF_CHARTS[@]} -gt 0 ]]; then
  printf "\n  ${C_BOLD}Charts with differences:${C_RESET}\n"
  for c in "${DIFF_CHARTS[@]}"; do
    printf "    ${C_RED}%s${C_RESET}\n" "$c"
  done
fi

print_separator
printf "\n"

cleanup_ref "$BASE_DIR"
cleanup_ref "$TARGET_DIR"

if [[ $DIFF_CNT -gt 0 || $MISMATCH -gt 0 ]]; then
  exit 1
fi
