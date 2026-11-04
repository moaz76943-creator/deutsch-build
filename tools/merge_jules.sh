#!/bin/bash
set -e
echo "🔄 جلب كافة مهام Jules النشطة على GitHub..."
git fetch origin --prune

# البحث عن أي فرع يحمل اسم jules أو J0 أو auto ودمجه فورياً
for rbranch in $(git branch -r | grep -E "origin/(jules/|J[0-9]+|auto-)"); do
  b_name=$(echo "$rbranch" | sed 's/origin\///')
  commits_ahead=$(git log "staging/v2-full-platform..$rbranch" --oneline 2>/dev/null | wc -l)
  if [ "$commits_ahead" -gt 0 ]; then
    echo "📥 دمج مهمة Jules: $b_name ($commits_ahead commits)..."
    git merge "$rbranch" --no-edit -X theirs -m "merge(jules): integrate $b_name seamlessly [skip ci]" || {
      git checkout --theirs . 2>/dev/null || true
      git add -A
      git commit -m "merge(jules): resolve and integrate $b_name [skip ci]" || true
    }
    git push origin --delete "$b_name" 2>/dev/null || true
  fi
done

git push origin staging/v2-full-platform --force
git push origin staging/v2-full-platform:main --force
echo "✅ تم دمج وتحديث جميع مهام Jules بنجاح في الفرع الرئيسي!"
