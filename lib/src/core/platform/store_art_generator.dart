enum DeviceFormFactor {
  phonePortrait,  // 1080 x 2400 (Android) / 1290 x 2796 (iOS)
  tabletLandscape, // 2560 x 1600
  wearSmartwatch, // 454 x 454
}

class StoreScreenshotScene {
  final String sceneId;
  final String headlineText;
  final String subHeadlineText;
  final String featureBadge;
  final String accentGradientHex;

  const StoreScreenshotScene({
    required this.sceneId,
    required this.headlineText,
    required this.subHeadlineText,
    required this.featureBadge,
    this.accentGradientHex = '#4facfe',
  });
}

class StoreArtGenerator {
  const StoreArtGenerator();

  /// Renders standalone, production-ready SVG store screenshot banner.
  String renderStoreBannerSvg({
    required StoreScreenshotScene scene,
    required DeviceFormFactor formFactor,
    required String localeCode,
  }) {
    int width = 1080;
    int height = 2400;

    if (formFactor == DeviceFormFactor.tabletLandscape) {
      width = 2560;
      height = 1600;
    } else if (formFactor == DeviceFormFactor.wearSmartwatch) {
      width = 454;
      height = 454;
    }

    final escapedHeadline = _xmlEscape(scene.headlineText);
    final escapedSub = _xmlEscape(scene.subHeadlineText);
    final escapedBadge = _xmlEscape(scene.featureBadge);

    return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $width $height" width="$width" height="$height">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#05070a"/>
      <stop offset="60%" stop-color="#0f141c"/>
      <stop offset="100%" stop-color="#1b2433"/>
    </linearGradient>
  </defs>

  <!-- Background -->
  <rect width="$width" height="$height" fill="url(#bgGrad)"/>

  <!-- Top Marketing Headers -->
  <rect x="${(width - 400) ~/ 2}" y="120" width="400" height="48" fill="#1e293b" rx="24"/>
  <text x="${width ~/ 2}" y="152" fill="${scene.accentGradientHex}" font-family="system-ui, sans-serif" font-size="20" font-weight="800" text-anchor="middle" letter-spacing="2">$escapedBadge</text>

  <text x="${width ~/ 2}" y="270" fill="#ffffff" font-family="system-ui, sans-serif" font-size="52" font-weight="900" text-anchor="middle">$escapedHeadline</text>
  <text x="${width ~/ 2}" y="340" fill="#94a3b8" font-family="system-ui, sans-serif" font-size="28" font-weight="500" text-anchor="middle">$escapedSub</text>

  <!-- Mockup Device Bezel Placeholder -->
  <rect x="90" y="440" width="${width - 180}" height="${height - 520}" rx="48" fill="#000000" stroke="#334155" stroke-width="8"/>
  <rect x="110" y="460" width="${width - 220}" height="${height - 560}" rx="36" fill="#090d16"/>
  <text x="${width ~/ 2}" y="${height ~/ 2}" fill="#475569" font-family="system-ui, sans-serif" font-size="32" text-anchor="middle">Polyglot Sovereign UI Mockup ($localeCode)</text>
</svg>''';
  }

  /// Maps target scene to Fastlane standard filesystem relative path.
  String resolveFastlanePath(String localeCode, String sceneId, DeviceFormFactor formFactor) {
    final deviceFolder = formFactor == DeviceFormFactor.tabletLandscape ? 'sevenInchScreenshots' : 'phoneScreenshots';
    return 'fastlane/metadata/android/$localeCode/images/$deviceFolder/$sceneId.svg';
  }

  String _xmlEscape(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
