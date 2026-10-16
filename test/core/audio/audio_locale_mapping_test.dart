import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/audio_locale_mapping.dart';

void main() {
  group('AudioLocaleMapping', () {
    test('polyglotLocales covers at least 100 languages', () {
      expect(AudioLocaleMapping.polyglotLocales.length, greaterThanOrEqualTo(100));
    });

    test('exact matching works', () {
      final available = ['es-ES', 'fr-FR', 'en-US'];
      expect(AudioLocaleMapping.resolveOfflineCapability('es-ES', available), 'es-ES');
      expect(AudioLocaleMapping.resolveOfflineCapability('fr-FR', available), 'fr-FR');
    });

    test('language-only exact match against available full locales works', () {
      final available = ['es-ES', 'fr-FR'];
      expect(AudioLocaleMapping.resolveOfflineCapability('es', available), 'es-ES');
    });

    test('mapping from language code using polyglotLocales works', () {
      final available = ['ar-SA', 'de-DE'];
      expect(AudioLocaleMapping.resolveOfflineCapability('ar', available), 'ar-SA');
    });

    test('approved fallbacks works', () {
      final available = ['es-ES', 'en-US'];
      expect(AudioLocaleMapping.resolveOfflineCapability('es-MX', available), 'es-ES');
      expect(AudioLocaleMapping.resolveOfflineCapability('en-GB', available), 'en-US');
    });

    test('mapped locale from polyglotLocales fallback works', () {
      // polyglotLocales maps 'en' -> 'en-US'
      // available is 'en-US', requested is 'en-GB'
      final available = ['en-US'];
      expect(AudioLocaleMapping.resolveOfflineCapability('en-GB', available), 'en-US');
    });

    test('returns null if voice missing', () {
      final available = ['fr-FR'];
      expect(AudioLocaleMapping.resolveOfflineCapability('de', available), isNull);
    });

    test('does not silently fallback to en or de', () {
       final available = ['en-US', 'de-DE'];
       expect(AudioLocaleMapping.resolveOfflineCapability('ar', available), isNull);
    });
  });
}
