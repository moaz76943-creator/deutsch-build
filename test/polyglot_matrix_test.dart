import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/language_pack_manager.dart';

void main() {
  test('100 Polyglot Matrix Data & Architecture Verification', () {
    final langs = LanguagePackManager.supportedLanguages;
    expect(
      langs.length,
      66,
      reason: 'الكتالوج الفعلي فيه 66 رمز لغة، وليس 100 لغة مُختلقة',
    );

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
