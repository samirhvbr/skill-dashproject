#!/usr/bin/env bash
# DASHPROJECT post-commit — record burst timestamp only.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
subject=$(git log -1 --pretty=%s)
case "$subject" in
  chore\(dashproject\)*) exit 0 ;;
esac

dir="$root/.dashproject"
mkdir -p "$dir"
date +%s > "$dir/last-commit-ts"
echo "pending $(git rev-parse --short HEAD) $subject" > "$dir/pending"
exit 0
