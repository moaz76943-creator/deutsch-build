#!/bin/bash
set -e
cd "$HOME/projects/.polyglot_merge_workspace/deutsch-build" || exit 1
rm -f .git/index.lock .git/HEAD.lock .git/MERGE_HEAD 2>/dev/null || true
python3 tools/sovereign_master_agent.py
