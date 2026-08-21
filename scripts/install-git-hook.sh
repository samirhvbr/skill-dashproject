#!/usr/bin/env bash
# Install a post-commit hook that records a DASHPROJECT pending review.
# The hook does not call a model. The agent runs the analysis after debounce.
set -euo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "not a git repository" >&2
  exit 1
}

mkdir -p "$root/.dashproject" "$root/.git/hooks"
hook="$root/.git/hooks/post-commit"

if [[ -f "$hook" ]] && ! grep -q "DASHPROJECT" "$hook"; then
  echo "existing post-commit hook at $hook — append DASHPROJECT block manually" >&2
  exit 2
fi

cp "$(dirname "$0")/post-commit.sh" "$hook"
chmod +x "$hook"
echo "installed $hook"
echo "debounce is read from .dashproject/config.yaml (default 10 min)"
