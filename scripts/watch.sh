#!/usr/bin/env bash
# Debounce watcher. Writes .dashproject/review-due when a review is owed.
# Does not call a model.
set -euo pipefail

once=0
if [[ "${1:-}" == "--once" ]]; then
  once=1
fi

here=$(cd "$(dirname "$0")" && pwd)
ready="$here/pending-ready.sh"

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "not a git repository" >&2
  exit 1
}
due="$root/.dashproject/review-due"

poll=30
cfg="$root/.dashproject/config.yaml"
if [[ -f "$cfg" ]]; then
  p=$(grep -E 'poll_seconds:' "$cfg" | head -1 | awk '{print $2}' || true)
  [[ -n "${p:-}" ]] && poll="$p"
fi

notify_cmd=""
if [[ -f "$cfg" ]]; then
  n=$(grep -E '^review_notify:' "$cfg" | head -1 | sed 's/^review_notify:[[:space:]]*//' | tr -d '"' || true)
  [[ -n "${n:-}" && "$n" != "''" && "$n" != '""' ]] && notify_cmd="$n"
fi

mark_due() {
  echo "review-due $(date -Iseconds) $($ready | head -1)" > "$due"
  echo "wrote $due"
  if [[ -n "$notify_cmd" ]]; then
    # shellcheck disable=SC2086
    eval "$notify_cmd" || true
  fi
}

if [[ "$once" == 1 ]]; then
  if "$ready"; then
    mark_due
    exit 0
  fi
  echo "not due"
  exit 2
fi

echo "watching $root (poll ${poll}s) — no LLM"
while true; do
  if [[ -f "$root/.dashproject/pending" ]] && "$ready"; then
    if [[ ! -f "$due" ]]; then
      mark_due
    fi
  fi
  sleep "$poll"
done
