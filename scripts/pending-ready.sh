#!/usr/bin/env bash
# Exit 0 if a pending DASHPROJECT review is older than debounce.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cfg="$root/.dashproject/config.yaml"
tsf="$root/.dashproject/last-commit-ts"
pend="$root/.dashproject/pending"

[[ -f "$pend" && -f "$tsf" ]] || exit 1

minutes=10
if [[ -f "$cfg" ]]; then
  m=$(grep -E 'debounce_minutes:' "$cfg" | head -1 | awk '{print $2}' || true)
  [[ -n "${m:-}" ]] && minutes="$m"
fi

now=$(date +%s)
last=$(cat "$tsf")
need=$(( minutes * 60 ))
age=$(( now - last ))
if (( age >= need )); then
  echo "ready age=${age}s debounce=${need}s"
  exit 0
fi
echo "wait remaining=$(( need - age ))s"
exit 2
