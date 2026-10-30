import 'package:test/test.dart';
import '../../lib/src/content/app_localization_catalog.dart';

void main() {
  group('AppLocalizationCatalog Unit Tests (L003)', () {
    test('Resolves localized UI strings across German, Arabic, Syriac, and Maltese', () {
      expect(AppLocalizationCatalog.translate('app_title', locale: 'ar'), equals('بوليجلوت السيادي'));
      expect(AppLocalizationCatalog.translate('app_title', locale: 'de'), equals('Polyglot Souverän'));
      expect(AppLocalizationCatalog.translate('start_practice', locale: 'ar'), equals('ابدأ التدريب'));
      expect(AppLocalizationCatalog.translate('privacy_notice', locale: 'mt'), contains('100% Offline'));
    });

    test('Correctly identifies Right-to-Left (RTL) scripts', () {
      expect(AppLocalizationCatalog.isRtl('ar'), isTrue);
      expect(AppLocalizationCatalog.isRtl('syc'), isTrue);
      expect(AppLocalizationCatalog.isRtl('de'), isFalse);
      expect(AppLocalizationCatalog.isRtl('en'), isFalse);
    });

    test('Falls back gracefully to German when key or locale is missing', () {
      final fallback = AppLocalizationCatalog.translate('app_title', locale: 'unknown_lang');
      expect(fallback, equals('Polyglot Souverän'));
    });
  });
}
