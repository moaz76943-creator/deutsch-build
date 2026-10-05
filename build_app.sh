#!/bin/bash
set -e
echo "-> معالجة الاستيرادات الزائدة وتحديث الأكواد..."
dart fix --apply
echo "-> تنظيف الكاش المؤقت المتضرر..."
rm -rf build/ android/.cxx/ android/app/.cxx/
echo "-> بدء تجميع ملف الـ APK..."
flutter build apk --debug
echo "-> اكتمل البناء بنجاح! مسار الملف:"
ls -lh build/app/outputs/flutter-apk/app-debug.apk
