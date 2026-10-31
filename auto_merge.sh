#!/bin/bash
# Fail closed. This script used to merge the first 100 open PRs into
# whatever base they had (usually main) without reading the diff.
set -euo pipefail

echo "auto_merge.sh refuses to merge."
echo "Integration branch is staging/v2-full-platform."
echo "Merge one verified PR at a time with: gh pr merge <number> --squash"
echo "Do not merge drafts, conflicting PRs, or PRs whose base is main."
exit 1
