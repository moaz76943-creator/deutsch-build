/// Specifications for an automated store listing screenshot asset.
class StoreScreenshotSpec {
  final String locale;
  final String deviceType; // 'phone_portrait', 'tablet_landscape', 'desktop'
  final int widthPixels;
  final int heightPixels;
  final String headlineText;

  const StoreScreenshotSpec({
    required this.locale,
    required this.deviceType,
    required this.widthPixels,
    required this.heightPixels,
    required this.headlineText,
  });
}

/// Headless generator of localized store banners and reproducible metadata screenshots.
class StoreArtScreenshotSynthesizer {
  static const Map<String, String> localizedHeadlines = {
    'de': 'Lerne 100 Sprachen vollkommen offline und souverän.',
    'ar': 'تعلّم 100 لغة بدون إنترنت بسيادة وخصوصية تامة.',
    'en': 'Master 100 languages 100% offline with zero cloud telemetry.',
    'syc': 'ܝܠܦ ܡܐܐ ܠܫܢ̈ܐ ܕܠܐ ܢܘܠܐ ܒܚܐܪܘܬܐ ܡܫܡܠܝܬܐ.',
    'mt': 'Tgħallem 100 lingwa offline b’sovranità sħiħa.',
  };

  /// Builds screenshot specifications matching F-Droid fastlane metadata standards.
  StoreScreenshotSpec buildSpec({
    required String locale,
    required String deviceType,
  }) {
    int w = 1080;
    int h = 1920;
    if (deviceType == 'tablet_landscape') {
      w = 2560;
      h = 1600;
    } else if (deviceType == 'desktop') {
      w = 1920;
      h = 1080;
    }

    final headline = localizedHeadlines[locale.toLowerCase()] ?? localizedHeadlines['en']!;

    return StoreScreenshotSpec(
      locale: locale,
      deviceType: deviceType,
      widthPixels: w,
      heightPixels: h,
      headlineText: headline,
    );
  }
}
