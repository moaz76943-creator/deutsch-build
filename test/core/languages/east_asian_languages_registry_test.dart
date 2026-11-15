import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/languages/declarative_language_engine.dart';
import 'package:deutsch_build/src/core/languages/east_asian_languages_registry.dart';

void main() {
  group('EastAsianLanguagesRegistry Tests (JA, ZH, KO)', () {
    late DeclarativeLanguageEngine engine;

    setUp(() {
      engine = DeclarativeLanguageEngine()..initialize();
      EastAsianLanguagesRegistry.registerProfiles(engine);
    });

    test('Registers Japanese, Chinese, and Korean successfully', () {
      expect(engine.getProfile('ja'), isNotNull);
      expect(engine.getProfile('zh'), isNotNull);
      expect(engine.getProfile('ko'), isNotNull);

      final ja = engine.getProfile('ja')!;
      expect(ja.autonym, equals('日本語'));
      expect(ja.typology, equals('SOV'));
      expect(ja.morphologyType, equals('Agglutinative'));

      final zh = engine.getProfile('zh')!;
      expect(zh.autonym, equals('中文'));
      expect(zh.morphologyType, equals('Isolating'));
      expect(zh.hasVerbConjugation, isFalse);

      final ko = engine.getProfile('ko')!;
      expect(ko.autonym, equals('한국어'));
      expect(ko.scriptFamily, equals('Hangul'));
      expect(ko.typology, equals('SOV'));
    });
  });
}
