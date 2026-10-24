import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/bcp47_locale_registry.dart';

void main() {
  group('Bcp47LocaleRegistry', () {
    test('Returns exact BCP-47 for valid catalog ID', () {
      expect(Bcp47LocaleRegistry.getBcp47Locale('de'), 'de-DE');
      expect(Bcp47LocaleRegistry.getBcp47Locale('fr'), 'fr-FR');
      expect(Bcp47LocaleRegistry.getBcp47Locale('zh'), 'zh-CN');
    });

    test('Returns null for unknown catalog ID', () {
      expect(Bcp47LocaleRegistry.getBcp47Locale('unknown_id'), isNull);
    });

    test('Returns regional fallback if mapped', () {
      expect(Bcp47LocaleRegistry.getFallbackLocale('es-AR'), 'es-ES');
      expect(Bcp47LocaleRegistry.getFallbackLocale('fr-CA'), 'fr-FR');
      expect(Bcp47LocaleRegistry.getFallbackLocale('en-GB'), 'en-US');
    });

    test('Returns null regional fallback if not mapped', () {
      expect(Bcp47LocaleRegistry.getFallbackLocale('de-DE'), isNull);
      expect(Bcp47LocaleRegistry.getFallbackLocale('es-ES'), isNull);
    });

    test('resolveCandidates provides strict order', () {
      expect(Bcp47LocaleRegistry.resolveCandidates('af'), ['af-ZA']);

      // zh -> zh-CN, no fallback mapped for zh-CN itself (zh-HK maps to zh-CN)
      expect(Bcp47LocaleRegistry.resolveCandidates('zh'), ['zh-CN']);

      // Let's test a hypothetical ID if we added one, but let's test how resolve candidates acts on existing map
      // Actually our map maps id to BCP47, then tries fallback on that BCP47.
      // Wait, is there any ID in languages that maps directly to a fallbackable locale?
      // Let's check 'zh-TW'. It maps to 'zh-TW'. Fallback for 'zh-TW' is 'zh-CN'.
      expect(Bcp47LocaleRegistry.resolveCandidates('zh-TW'), ['zh-TW', 'zh-CN']);

      expect(Bcp47LocaleRegistry.resolveCandidates('invalid'), <String>[]);
    });

    test('100-ID completeness check', () {
      final List<String> ids = [
        'af', 'sq', 'am', 'ar', 'hy', 'az', 'eu', 'be', 'bn', 'bs', 'bg', 'ca',
        'ceb', 'ny', 'zh', 'zh-TW', 'co', 'hr', 'cs', 'da', 'nl', 'en', 'eo',
        'et', 'tl', 'fi', 'fr', 'fy', 'gl', 'ka', 'de', 'el', 'gu', 'ht', 'ha',
        'haw', 'he', 'hi', 'hmn', 'hu', 'is', 'ig', 'id', 'ga', 'it', 'ja', 'jv',
        'kn', 'kk', 'km', 'ko', 'ku', 'ky', 'lo', 'la', 'lv', 'lt', 'lb', 'mk',
        'mg', 'ms', 'ml', 'mt', 'mi', 'mr', 'mn', 'my', 'ne', 'no', 'or', 'ps',
        'fa', 'pl', 'pt', 'pa', 'ro', 'ru', 'sm', 'gd', 'sr', 'st', 'sn', 'sd',
        'si', 'sk', 'sl', 'so', 'es', 'su', 'sw', 'sv', 'tg', 'ta', 'te', 'th',
        'tr', 'uk', 'ur', 'ug', 'uz', 'vi', 'cy', 'xh', 'yi', 'yo', 'zu'
      ];
      expect(ids.length, greaterThanOrEqualTo(100));
      for (var id in ids) {
        expect(Bcp47LocaleRegistry.getBcp47Locale(id), isNotNull);
      }
    });
  });
}
