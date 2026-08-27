#!/usr/bin/env bash
# Commits the DASHPROJECT snapshot — and only it. Never pushes, never calls a model.
#
# The subject starts with `chore(dashproject)`, which the post-commit hook ignores:
# that is what stops the review from re-arming itself. Closing the tree is the other
# half — an auditor that writes files and walks away leaves them for whatever else
# commits in that repository, and the snapshot comes back as someone else's commit,
# which does re-arm the hook.
#
# Pathspec, never `-A`: work in progress belongs to the implementer, and a partial
# commit leaves their staged files staged.
set -euo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "not a git repository" >&2
  exit 1
}
dp="$root/.dashproject"
[[ -d "$dp" ]] || { echo "no .dashproject/ — run bootstrap first" >&2; exit 1; }

# Absent key means an install older than the one that introduced it: default to
# committing, because that is the behaviour that keeps the tree closed. `false` is
# honored — it is the opt-out for a repository that wants the snapshot reviewed by
# hand before it enters history.
auto=true
cfg="$dp/config.yaml"
if [[ -f "$cfg" ]]; then
  v=$(grep -E '^[[:space:]]*auto_commit:' "$cfg" | head -1 | awk '{print $2}' || true)
  [[ -n "${v:-}" ]] && auto="$v"
fi
if [[ "$auto" != "true" ]]; then
  echo "auto_commit: $auto — snapshot written, tree left dirty on purpose"
  exit 0
fi

git -C "$root" add -- .dashproject
if git -C "$root" diff --cached --quiet -- .dashproject; then
  echo "nothing new under .dashproject/"
  exit 0
fi

msg=$(python3 - "$dp/dashboard/data.json" <<'PY'
import json
import pathlib
import sys

data = {}
try:
    data = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
except (OSError, ValueError):
    pass  # no snapshot to quote: a generic subject is still true

bits = []
for key, label in (("snapshot", "snapshot"), ("progress", "progress"),
                   ("precision", "precision")):
    value = data.get(key)
    if value is not None:
        bits.append(f"{label} {value}%" if key != "snapshot" else f"snapshot {value}")
print("chore(dashproject): " + (" · ".join(bits) if bits else "snapshot"))
print()

head = data.get("head")
if head:
    print(f"Range: {data.get('base') or 'BASE'}..{head}")
# Never a `Requirements:` block here: this commit declares nothing, and the parser
# would read it if it did.
print("Written-By: dashproject")
PY
)

subject=$(printf '%s\n' "$msg" | head -1)
body=$(printf '%s\n' "$msg" | tail -n +3)
args=(-m "$subject")
[[ -n "$body" ]] && args+=(-m "$body")

git -C "$root" commit -q "${args[@]}" -- .dashproject
echo "$(git -C "$root" rev-parse --short HEAD) $subject"
