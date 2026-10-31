#!/bin/bash
set -e

echo "🛠️ 1. تشغيل الإصلاح التلقائي والفحص..."
./autofix.sh

echo "📦 2. حفظ أي تعديلات متبقية..."
git add .
# إذا كانت هناك تعديلات جديدة لم تُحفظ
if ! git diff-index --quiet HEAD --; then
    MSG=${1:-"chore: automated update and sync"}
    git commit -m "$MSG"
fi

echo "🔄 3. مزامنة الفرع الرئيسي (main)..."
CURRENT_BRANCH=$(git branch --show-current)
git checkout main
git merge "$CURRENT_BRANCH" -m "chore: sync from $CURRENT_BRANCH"
git push origin main

echo "↩️ 4. العودة إلى فرع التطوير ورفع التحديثات..."
git checkout "$CURRENT_BRANCH"
git push origin "$CURRENT_BRANCH"

echo "🚀 تم الشحن والمزامنة بالكامل بنجاح!"
