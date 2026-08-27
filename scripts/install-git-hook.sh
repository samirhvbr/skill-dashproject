#!/usr/bin/env bash
# Insert or refresh the DASHPROJECT post-commit block. Never replaces an
# existing hook body outside the markers.
set -euo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "not a git repository" >&2
  exit 1
}

hook="$root/.git/hooks/post-commit"
here=$(cd "$(dirname "$0")" && pwd)
block_file="$here/hook-block.sh"
[[ -f "$block_file" ]] || { echo "missing $block_file" >&2; exit 1; }

mkdir -p "$root/.dashproject" "$root/.git/hooks"
block=$(cat "$block_file")
begin='# >>> DASHPROJECT >>>'
end='# <<< DASHPROJECT <<<'

if [[ ! -f "$hook" ]]; then
  printf '#!/usr/bin/env bash\nset -euo pipefail\n\n%s\n' "$block" > "$hook"
  echo "created $hook"
else
  tmp=$(mktemp)
  if grep -q "$begin" "$hook" && grep -q "$end" "$hook"; then
    # The block goes through the environment, never through `awk -v`: -v processes
    # escape sequences, so `chore\(dashproject\)*)` came out as
    # `chore(dashproject)*)` and the rewritten hook died with a bash syntax error on
    # every commit — the hook stops recording `pending` and the auditor is never
    # armed again, silently. Only the refresh path was affected; a fresh install
    # writes the block with printf.
    DP_BLOCK="$block" awk -v b="$begin" -v e="$end" '
      $0 == b { print ENVIRON["DP_BLOCK"]; skip=1; next }
      $0 == e { skip=0; next }
      skip { next }
      { print }
    ' "$hook" > "$tmp"
    echo "refreshed DASHPROJECT block in $hook"
  else
    cat "$hook" > "$tmp"
    printf '\n%s\n' "$block" >> "$tmp"
    echo "appended DASHPROJECT block to $hook"
  fi
  mv "$tmp" "$hook"
fi

chmod +x "$hook"
cp "$here/watch.sh" "$root/.dashproject/watch.sh"
cp "$here/pending-ready.sh" "$root/.dashproject/pending-ready.sh"
cp "$here/commit-snapshot.sh" "$root/.dashproject/commit-snapshot.sh"
cp "$here/collect-activity.py" "$root/.dashproject/collect-activity.py"
cp "$here/render-reports.py" "$root/.dashproject/render-reports.py"
chmod +x "$root/.dashproject/watch.sh" "$root/.dashproject/pending-ready.sh" \
  "$root/.dashproject/commit-snapshot.sh" \
  "$root/.dashproject/collect-activity.py" "$root/.dashproject/render-reports.py"
echo "hook does not call a model; use dashproject watch or review"
