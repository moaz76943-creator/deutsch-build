#!/usr/bin/env bash

APP_DIR="$HOME/projects/.polyglot_merge_workspace/deutsch-build"
cd "$APP_DIR" || { echo "[FAIL] Directory not found"; exit 1; }

echo "========================================================================"
echo "   HARVESTING ALL HISTORICAL SCRIPTS, TOOLS & DATABASE UTILITIES        "
echo "========================================================================"

git checkout staging/v2-full-platform

echo "[1/4] Ensuring all historical branches and tags are mapped..."
git fetch origin --tags 2>/dev/null || true

# إنشاء مجلدات منظمة للأدوات والسكربتات
mkdir -p scripts/db scripts/audio scripts/build scripts/audit tool/

echo "[2/4] Harvesting historical scripts and tools across all Git commits..."
# البحث عن أي ملف سكربت أو أداة بايثون أو باش أو إس كيو إل عبر تاريخ Git
for commit in $(git log --all --format="%H" -n 250); do
  for file in $(git diff-tree --no-commit-id --name-only -r "$commit" 2>/dev/null); do
    case "$file" in
      scripts/*|tool/*|tools/*|*.py|*.sh|*.sql)
        git checkout "$commit" -- "$file" 2>/dev/null || true
        ;;
    esac
  done
done

# فحص ما إذا كان هناك سكربتات في المستودع العام لمصنع الحزم إن وجد محلياً
PACKS_STORE="$HOME/projects/.polyglot_merge_workspace/-offline-packs-store"
if [ -d "$PACKS_STORE" ]; then
  echo " -> Syncing public content factory pack generator scripts..."
  mkdir -p scripts/content_factory
  cp -r "$PACKS_STORE"/*.py "$PACKS_STORE"/scripts/* scripts/content_factory/ 2>/dev/null || true
fi

echo "[3/4] Staging and committing all legacy tools and scripts..."
git add -A scripts/ tool/ assets/database/
git commit -m "chore: consolidate all legacy engineering scripts, tools, and DB utilities" 2>/dev/null || echo "All scripts already staged."

echo "[4/4] Pushing consolidated tools to GitHub staging..."
for attempt in 1 2 3 4; do
  git push origin staging/v2-full-platform && break || sleep 3
done

echo ""
echo "========================================================================"
echo "📦 EXHAUSTIVE INVENTORY OF SCRIPTS & TOOLS IN REPOSITORY:"
echo "------------------------------------------------------------------------"
find scripts tool -type f 2>/dev/null | sort | while read -r script_path; do
  echo "  ✔ $script_path"
done
echo "------------------------------------------------------------------------"
echo "Total Shell & Python Scripts Secured: $(find scripts tool -type f \( -name "*.sh" -o -name "*.py" \) 2>/dev/null | wc -l)"
echo "Total Database Files & Assets:       $(find assets/database -type f 2>/dev/null | wc -l)"
echo "========================================================================"
