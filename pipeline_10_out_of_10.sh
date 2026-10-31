#!/usr/bin/env bash
set -e

echo "📦 [1/5] تسجيل مجلد أصول الـ 100 لغة في pubspec.yaml وتحديث الحزم..."
python3 -c "
with open('pubspec.yaml', 'r', encoding='utf-8') as f:
    c = f.read()

target = '    - assets/data/packs/'
if target not in c:
    if 'assets:' in c:
        c = c.replace('assets:', 'assets:\n' + target)
    else:
        c = c.replace('flutter:\n', 'flutter:\n  assets:\n' + target + '\n')
    with open('pubspec.yaml', 'w', encoding='utf-8') as f:
        f.write(c)
    print('✅ تم إدراج assets/data/packs/ في pubspec.yaml')
else:
    print('ℹ️ مسار الحزم مسجل مسبقاً.')
"
flutter pub get

echo "🧪 [2/5] إنشاء حزمة اختبارات الجودة لمصفوفة الـ 100 لغة (Zero-Defect Test)..."
cat << 'TEST_EOF' > test/polyglot_matrix_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/language_pack_manager.dart';

void main() {
  test('100 Polyglot Matrix Data & Architecture Verification', () {
    final langs = LanguagePackManager.supportedLanguages;
    expect(langs.length, 100, reason: 'يجب أن تحتوي المنظومة على 100 لغة بالضبط');

    for (final code in langs) {
      final name = LanguagePackManager.getLanguageName(code);
      final tts = LanguagePackManager.getTtsLocale(code);

      expect(name.isNotEmpty, true, reason: 'اسم اللغة غير معرّف للرمز: $code');
      expect(tts.isNotEmpty, true, reason: 'نظام النطق غير معرّف للرمز: $code');

      final file = File('assets/data/packs/${code}_pack.json');
      expect(file.existsSync(), true, reason: 'ملف الحزمة غير موجود: $code');

      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;
      expect(data['items'] is List, true);

      final items = data['items'] as List;
      expect(items.isNotEmpty, true, reason: 'حزمة اللغة فارغة: $code');

      final item = items.first as Map<String, dynamic>;
      expect(item['word'] != null && item['word'].toString().isNotEmpty, true);
      expect(item['meaning'] != null && item['meaning'].toString().isNotEmpty, true);
      expect(item['example'] != null && item['example'].toString().isNotEmpty, true);
    }
  });
}
TEST_EOF

echo "⚡ [3/5] تشغيل كافة اختبارات الوحدة المعمارية (SRS Engine + 100 Languages)..."
flutter test test/srs_engine_test.dart test/polyglot_matrix_test.dart

echo "🏗️ [4/5] إعداد خط الإنتاج السحابي المؤتمت لبناء الـ APK (GitHub Actions CI/CD)..."
mkdir -p .github/workflows
cat << 'WORKFLOW_EOF' > .github/workflows/build_apk.yml
name: Build Production Release APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Set up Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Install Dependencies
        run: flutter pub get

      - name: Run Quality Gate Tests
        run: flutter test

      - name: Build Release APK
        run: flutter build apk --release --split-per-abi

      - name: Upload APK Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: release-apks
          path: build/app/outputs/flutter-apk/*.apk
WORKFLOW_EOF

echo "🚀 [5/5] حفظ واعتماد كافة الملفات ورفعها إلى GitHub..."
git add .
git commit -m "feat(polyglot): achieve 10/10 milestone - 100 languages matrix, unit tests, and CI/CD build pipeline" || true
git push origin main

echo "🎉 اكتملت المنظومة 10 من 10 بنجاح فائق! تم تشغيل الفحوصات ورفع المشروع، وسيبدأ بناء حزم الـ APK سحابياً فوراً."
