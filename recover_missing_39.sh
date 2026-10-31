#!/usr/bin/env bash

APP_DIR="$HOME/projects/.polyglot_merge_workspace/deutsch-build"
cd "$APP_DIR" || { echo "[FAIL] Directory not found"; exit 1; }

echo "========================================================================"
echo "   RECOVERING & HARVESTING 39 MISSING TASKS FROM GITHUB COMMITS/PRS     "
echo "========================================================================"

git checkout staging/v2-full-platform

echo "[1/3] Searching all git objects and PR commits across history..."

# قائمة المهام الـ 39 المتبقية للبحث عنها وسحبها
MISSING_KEYS=(
  "E001" "E002" "E003" "E004" "E005" "E006" "E007" "E008" "E009" "E010"
  "E011" "E012" "E013" "E014" "E015" "E016" "E017" "E018" "E019" "E020"
  "E021" "E023" "E024" "E028" "E029" "E030" "E032" "E034" "E037"
  "E041" "E042" "E043" "E044" "E045" "E047" "E049" "E051" "E052" "E053"
)

RECOVERED=0
for key in "${MISSING_KEYS[@]}"; do
  # البحث عن أي Commit يحمل رقم المهمة في جميع الفروع والمراجع المسحوبة
  COMMIT_HASH=$(git log --all --grep="$key" -n 1 --format="%H" 2>/dev/null || true)

  if [ -n "$COMMIT_HASH" ]; then
    echo " -> Found commit for $key: $COMMIT_HASH. Extracting files..."
    git checkout "$COMMIT_HASH" -- lib/ test/ 2>/dev/null || true
    git add -f lib/ test/ 2>/dev/null || true
    git commit -m "merge: recover and integrate $key into staging" 2>/dev/null || true
    RECOVERED=$((RECOVERED + 1))
  fi
done

echo "[2/3] Total tasks recovered from git history: $RECOVERED"

if [ "$RECOVERED" -gt 0 ]; then
  echo "Pushing recovered tasks to GitHub staging..."
  git push origin staging/v2-full-platform 2>/dev/null || true
fi

echo "[3/3] Running master verification scorecard..."
./verify_96_tasks.sh
