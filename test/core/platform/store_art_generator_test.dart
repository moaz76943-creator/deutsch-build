import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/platform/store_art_generator.dart';

void main() {
  group('StoreArtGenerator Tests', () {
    const generator = StoreArtGenerator();

    const arabicScene = StoreScreenshotScene(
      sceneId: '01_hero_ai_dialogue',
      headlineText: 'تحدث الألمانية بطلاقة مع الذكاء الاصطناعي',
      subHeadlineText: 'بدون إنترنت وبخصوصية تامة على جهازك 100%',
      featureBadge: 'SOVEREIGN OFFLINE AI',
    );

    test('Renders valid phone portrait SVG banner with embedded Arabic typography', () {
      final svg = generator.renderStoreBannerSvg(
        scene: arabicScene,
        formFactor: DeviceFormFactor.phonePortrait,
        localeCode: 'ar',
      );

      expect(svg.startsWith('<svg'), isTrue);
      expect(svg.endsWith('</svg>'), isTrue);
      expect(svg, contains('viewBox="0 0 1080 2400"'));
      expect(svg, contains('تحدث الألمانية بطلاقة مع الذكاء الاصطناعي'));
      expect(svg, contains('SOVEREIGN OFFLINE AI'));
    });

    test('Renders high-res tablet landscape banner dimensions (2560x1600)', () {
      final svg = generator.renderStoreBannerSvg(
        scene: arabicScene,
        formFactor: DeviceFormFactor.tabletLandscape,
        localeCode: 'ar',
      );

      expect(svg, contains('viewBox="0 0 2560 1600"'));
    });

    test('Resolves correct Fastlane structured output path for Play Store publishing', () {
      final path = generator.resolveFastlanePath('de-DE', '01_hero', DeviceFormFactor.phonePortrait);
      expect(path, equals('fastlane/metadata/android/de-DE/images/phoneScreenshots/01_hero.svg'));
    });
  });
}
