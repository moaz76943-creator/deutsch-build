#!/usr/bin/env bash

echo "🚀 بدء خط الأتمتة الشامل لمعالجة طلبات السحب..."
PR_LIST=$(gh pr list --state open --limit 100 --json number --jq '.[].number' | sort -n)

for PR in $PR_LIST; do
  echo "========================================="
  echo "🔄 جاري معالجة PR #$PR تلقائياً..."
  
  git fetch origin pull/$PR/head:pr-$PR 2>/dev/null || continue
  
  if git merge --no-commit --no-ff pr-$PR 2>/dev/null; then
    echo "✅ دمج نظيف ومباشر لـ PR #$PR"
    git commit -m "Merge PR #$PR automatically"
    git push origin staging/v2-full-platform
  else
    echo "⚠️ تعارض مرصود في PR #$PR، تطبيق قواعد الحسم التلقائي..."
    # حسم ملفات القفل لصالح الفرع الأساسي
    git checkout --ours pubspec.lock 2>/dev/null || true
    # حسم الميزات والاختبارات لصالح التحديث الجديد
    git checkout --theirs lib/ test/ tools/ 2>/dev/null || true
    git add -A
    
    if git commit -m "Merge PR #$PR (Auto-resolved conflicts)" 2>/dev/null; then
      git push origin staging/v2-full-platform
      echo "✅ تم حسم التعارضات والدمج بنجاح لـ PR #$PR"
    else
      echo "❌ تعذر الحسم التلقائي لـ PR #$PR، تخطي للمتابعة..."
      echo "$PR" >> failed_prs.txt
      git merge --abort 2>/dev/null || true
    fi
  fi
done

echo "🎉 اكتملت الأتمتة بالكامل!"
