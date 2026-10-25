#!/usr/bin/env bash
# Fail closed. The previous script merged PR heads into staging with
# git checkout --ours/--theirs and pushed, which dropped one side of
# every conflict and raced other writers.
set -euo pipefail

echo "auto_merge_all.sh refuses to merge."
echo "Blind ours/theirs resolution and direct pushes are disabled."
echo "Verify the patch, then merge that PR into staging/v2-full-platform."
exit 1
