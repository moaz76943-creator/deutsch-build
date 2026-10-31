#!/usr/bin/env bash

APP_DIR="$HOME/projects/.polyglot_merge_workspace/deutsch-build"
cd "$APP_DIR" || { echo "[FAIL] Directory not found"; exit 1; }

echo "========================================================================"
echo "   INSPECTING LATEST COMMITTED FILES & STRUCTURE IN bf42b3b6            "
echo "========================================================================"

echo "[1/4] First 30 files committed in latest commit bf42b3b6:"
git show --name-only --oneline bf42b3b6 | head -n 30

echo ""
echo "[2/4] Checking lib/core vs lib/src/core:"
echo "Files directly in lib/core:"
find lib/core -name "*.dart" 2>/dev/null | head -n 10 || echo "None"

echo "Files in lib/src/core:"
find lib/src/core -name "*.dart" 2>/dev/null | head -n 10 || echo "None"

echo ""
echo "[3/4] Language profile JSONs in assets/languages/profiles:"
ls -1 assets/languages/profiles/*.json 2>/dev/null | wc -l

echo ""
echo "[4/4] Total Assets & Code Inventory:"
echo "   - Total Dart files in lib/:  $(find lib -name "*.dart" 2>/dev/null | wc -l)"
echo "   - Total Dart files in test/: $(find test -name "*.dart" 2>/dev/null | wc -l)"
echo "   - Total files in assets/:    $(find assets -type f 2>/dev/null | wc -l)"
echo "========================================================================"
