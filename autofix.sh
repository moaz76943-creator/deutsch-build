#!/bin/bash
set -e

echo "🔧 جارٍ تطبيق الإصلاحات التلقائية..."
dart fix --apply lib/

echo "📐 جارٍ تنسيق جميع الملفات..."
dart format lib/

echo "🔍 التحقق من خلو الكود من الأخطاء الحرجة..."
if dart analyze lib/ 2>&1 | grep -q "error •"; then
    echo "❌ توجد أخطاء برمجية حرجة تمنع الحفظ التلقائي!"
    exit 1
else
    echo "✅ الكود سليم وخالٍ من الأخطاء الحرجة."
fi

echo "📦 حفظ التعديلات في Git..."
git add lib/
if git diff --staged --quiet; then
    echo "✨ لا توجد تغييرات جديدة للحفظ."
else
    git commit -m "chore: automated code fixes and formatting"
    echo "🚀 تم حفظ التغييرات محلياً بنجاح."
fi
