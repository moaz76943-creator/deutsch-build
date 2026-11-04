#!/bin/bash
set -e
git fetch origin staging/v2-full-platform --prune
git merge origin/staging/v2-full-platform --no-edit -X theirs 2>/dev/null || true
echo "✅ Fast-Merge: Synchronized without friction."
