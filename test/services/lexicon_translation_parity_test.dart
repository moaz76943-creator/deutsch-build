import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flat Arabic string has priority over other translations', () {
    final result = DatabaseService.resolveLexiconTranslation({
      'translation_ar': 'كتاب',
      'translation': 'book',
      'translations': [
        {'languageCode': 'en', 'text': 'book'},
      ],
    });
    expect(result?.text, 'كتاب');
    expect(result?.languageCode, 'ar');
  });

  test('flat translation fallback respects its explicit language', () {
    final result = DatabaseService.resolveLexiconTranslation({
      'translation_ar': 42,
      'translation': 'house',
      'translationLanguageCode': 'en',
    });
    expect(result?.text, 'house');
    expect(result?.languageCode, 'en');
  });

  test('structured translation prefers Arabic over first other language', () {
    final result = DatabaseService.resolveLexiconTranslation({
      'translations': [
        {'languageCode': 'en', 'text': 'house'},
        {'languageCode': 'ar', 'text': 'بيت'},
      ],
    });
    expect(result?.text, 'بيت');
    expect(result?.languageCode, 'ar');
  });

  test('structured translation falls back to first valid text', () {
    final result = DatabaseService.resolveLexiconTranslation({
      'translations': [
        {'languageCode': 'de', 'text': 12},
        {'languageCode': 'en', 'text': 'house'},
      ],
    });
    expect(result?.text, 'house');
    expect(result?.languageCode, 'en');
  });

  test('English definition fallback retains real language tag', () {
    final result = DatabaseService.resolveLexiconTranslation({
      'translation': null,
      'translations': [],
      'definitions': [
        {'languageCode': 'en', 'text': 'a dwelling'},
      ],
    });
    expect(result?.text, 'a dwelling');
    expect(result?.languageCode, 'en');
  });

  test('invalid optional values do not produce bogus translations', () {
    expect(DatabaseService.resolveLexiconTranslation({
      'translation_ar': 42,
      'translation': [],
      'translations': [null, {'languageCode': 'ar', 'text': 5}],
      'definitions': [true, {'languageCode': 'en', 'text': null}],
    }), isNull);
  });
}
