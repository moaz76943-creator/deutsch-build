import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/platform/store_art_screenshot_synthesizer.dart';

void main() {
  group('StoreArtScreenshotSynthesizer Unit Tests (N088)', () {
    final synthesizer = StoreArtScreenshotSynthesizer();

    test('Generates localized phone screenshot spec for Arabic locale', () {
      final spec = synthesizer.buildSpec(locale: 'ar', deviceType: 'phone_portrait');
      expect(spec.locale, equals('ar'));
      expect(spec.widthPixels, equals(1080));
      expect(spec.heightPixels, equals(1920));
      expect(spec.headlineText, contains('100 لغة بدون إنترنت'));
    });

    test('Generates 2560x1600 tablet landscape spec for German locale', () {
      final spec = synthesizer.buildSpec(locale: 'de', deviceType: 'tablet_landscape');
      expect(spec.widthPixels, equals(2560));
      expect(spec.heightPixels, equals(1600));
      expect(spec.headlineText, contains('Lerne 100 Sprachen'));
    });

    test('Falls back gracefully to English for unmapped locales', () {
      final spec = synthesizer.buildSpec(locale: 'xyz', deviceType: 'desktop');
      expect(spec.headlineText, contains('Master 100 languages'));
    });
  });
}
