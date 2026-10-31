#!/bin/bash
# Fail closed. The previous script ran tests with '|| true', committed
# the whole worktree, and pushed to main.
set -euo pipefail

echo "auto_deploy.sh refuses to push."
echo "Direct pushes to main are disabled."
echo "Integrate verified work through a PR into staging/v2-full-platform."
exit 1
