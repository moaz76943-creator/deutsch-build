#!/usr/bin/env bash

echo "========================================="
echo "🔍 1. فحص حزم وأدوات النظام المتاحة"
echo "========================================="
echo "Dart:    $(which dart 2>/dev/null || echo 'غير مثبت')"
echo "Flutter: $(which flutter 2>/dev/null || echo 'غير مثبت')"
echo "FVM:     $(which fvm 2>/dev/null || echo 'غير مثبت')"
echo "Python:  $(python3 --version 2>/dev/null || echo 'غير مثبت')"

echo -e "\n========================================="
echo "📁 2. فحص إعدادات المشروع ونسخة Flutter المستهدفة"
echo "========================================="
if [ -f "pubspec.yaml" ]; then
  grep -E "(sdk:|flutter:)" pubspec.yaml -A 2
else
  echo "⚠️ ملف pubspec.yaml غير موجود في المسار الحالي!"
fi

if [ -d ".devcontainer" ]; then
  echo "تم العثور على إعدادات DevContainer:"
  ls -la .devcontainer/
fi

echo -e "\n========================================="
echo "🧪 3. التحقق من سلامة نصوص الشفاء الذاتي (Python)"
echo "========================================="
python3 -m unittest discover -s scripts/tests/ 2>&1 | tail -n 5

echo -e "\n✅ اكتمل الفحص الشامل!"
