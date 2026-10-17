#!/bin/bash

TARGET_BRANCH="staging/v2-full-platform"
CONFLICT_LOG="conflicts.log"
> "$CONFLICT_LOG"

echo "🔄 جلب قائمة طلبات السحب المفتوحة بترتيب تصاعدي..."
PR_LIST=$(gh pr list --state open --limit 100 --json number --jq 'sort_by(.number) | .[].number')

for PR in $PR_LIST; do
  echo "----------------------------------------"
  echo "🔍 فحص طلب السحب #$PR..."
  
  # محاولة الدمج المباشر
  if gh pr merge "$PR" --merge --subject "Auto-merge PR #$PR into $TARGET_BRANCH" 2>/dev/null; then
    echo "✅ تم دمج PR #$PR بنجاح!"
    git pull origin "$TARGET_BRANCH"
  else
    echo "⚠️ تعذر الدمج التلقائي لـ PR #$PR (قد يحتاج حل تعارض)."
    echo "$PR" >> "$CONFLICT_LOG"
  fi
done

echo "========================================"
echo "🎉 انتهت المهمة! الطلبات التي تحتاج مراجعة مسجلة في: $CONFLICT_LOG"
