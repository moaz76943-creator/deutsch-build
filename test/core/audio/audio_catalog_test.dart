import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/audio_catalog.dart';

void main() {
  test('AudioCatalog has 100 entries', () {
    final fallbacksCount = 100;
    int actualCount = 0;

    final allLangs = [
      'af', 'am', 'ar', 'az', 'be', 'bg', 'bn', 'bs', 'ca', 'cs', 'cy', 'da', 'de', 'el', 'en', 'es', 'et', 'eu', 'fa', 'fi', 'fr', 'ga', 'gl', 'gu', 'ha', 'he', 'hi', 'hr', 'hu', 'hy', 'id', 'ig', 'is', 'it', 'ja', 'jv', 'ka', 'kk', 'km', 'kn', 'ko', 'ky', 'lo', 'lt', 'lv', 'mg', 'mi', 'mk', 'ml', 'mn', 'mr', 'ms', 'mt', 'my', 'ne', 'nl', 'no', 'ny', 'or', 'pa', 'pl', 'ps', 'pt', 'ro', 'ru', 'rw', 'sd', 'si', 'sk', 'sl', 'sm', 'sn', 'so', 'sq', 'sr', 'st', 'su', 'sv', 'sw', 'ta', 'te', 'tg', 'th', 'tk', 'tl', 'tr', 'tt', 'ug', 'uk', 'ur', 'uz', 'vi', 'xh', 'yi', 'yo', 'zh', 'zu', 'ku', 'lb', 'eo'
    ];

    for (final lang in allLangs) {
      if (AudioCatalog.hasCapability(lang)) {
        actualCount++;
        final fallbacks = AudioCatalog.getFallbacks(lang);
        expect(fallbacks, isNotEmpty);
      }
    }

    expect(actualCount, equals(fallbacksCount));
  });

  test('AudioCatalog fallback rules prevent silent cross-language fallback', () {
    // Check Spanish
    final esFallbacks = AudioCatalog.getFallbacks('es');
    expect(esFallbacks, contains('es-ES'));
    expect(esFallbacks.any((f) => f.startsWith('en')), isFalse);
    expect(esFallbacks.any((f) => f.startsWith('de')), isFalse);

    // Check Arabic
    final arFallbacks = AudioCatalog.getFallbacks('ar');
    expect(arFallbacks, contains('ar-SA'));
    expect(arFallbacks.any((f) => f.startsWith('en')), isFalse);
  });
}
