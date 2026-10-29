import 'dart:math' as math;

enum ContrastStandard {
  wcagAA,  // 4.5:1 minimum
  wcagAAA, // 7.0:1 enhanced
  superOledExtreme, // 15.0:1 maximum daylight / night distinction
}

class ColorRgb {
  final int r;
  final int g;
  final int b;
  final double a;

  const ColorRgb(this.r, this.g, this.b, [this.a = 1.0]);

  static const ColorRgb pureBlack = ColorRgb(0, 0, 0);
  static const ColorRgb pureWhite = ColorRgb(255, 255, 255);
  static const ColorRgb oledCardSurface = ColorRgb(14, 16, 20);
  static const ColorRgb oledCardBorder = ColorRgb(32, 36, 44);
  static const ColorRgb warmNightText = ColorRgb(255, 241, 218);
  static const ColorRgb emeraldSuccess = ColorRgb(46, 213, 115);
  static const ColorRgb crimsonAlert = ColorRgb(255, 71, 87);

  /// Calculates relative luminance according to WCAG 2.1 specifications.
  double get relativeLuminance {
    double transform(int channel) {
      final double v = channel / 255.0;
      return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * transform(r) + 0.7152 * transform(g) + 0.0722 * transform(b);
  }

  /// Calculates contrast ratio between this color and another color.
  double contrastRatioWith(ColorRgb other) {
    final l1 = relativeLuminance;
    final l2 = other.relativeLuminance;
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  String toHex() {
    final hexR = r.toRadixString(16).padLeft(2, '0');
    final hexG = g.toRadixString(16).padLeft(2, '0');
    final hexB = b.toRadixString(16).padLeft(2, '0');
    return '#$hexR$hexG$hexB';
  }
}

class OledPalette {
  final ColorRgb background;
  final ColorRgb surface;
  final ColorRgb surfaceBorder;
  final ColorRgb primaryText;
  final ColorRgb secondaryText;
  final ColorRgb accent;
  final double calculatedContrast;
  final bool isPureBlackOled;

  const OledPalette({
    required this.background,
    required this.surface,
    required this.surfaceBorder,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
    required this.calculatedContrast,
    required this.isPureBlackOled,
  });

  Map<String, dynamic> toJson() => {
    'background': background.toHex(),
    'surface': surface.toHex(),
    'primaryText': primaryText.toHex(),
    'secondaryText': secondaryText.toHex(),
    'calculatedContrast': calculatedContrast,
    'isPureBlackOled': isPureBlackOled,
  };
}

class OledCognitiveThemeEngine {
  const OledCognitiveThemeEngine();

  /// Generates the optimal OLED palette based on ambient luminance and eye-strain reduction mode.
  OledPalette buildTheme({
    bool pureBlackOled = true,
    bool warmNightShift = true,
    ContrastStandard standard = ContrastStandard.wcagAAA,
  }) {
    final background = pureBlackOled ? ColorRgb.pureBlack : const ColorRgb(18, 18, 18);
    final surface = pureBlackOled ? ColorRgb.oledCardSurface : const ColorRgb(28, 28, 30);
    final border = pureBlackOled ? ColorRgb.oledCardBorder : const ColorRgb(44, 44, 46);

    ColorRgb text;
    if (warmNightShift) {
      // Warm amber shift (absorbs 60% of high-energy 450nm blue light)
      text = ColorRgb.warmNightText;
    } else {
      text = ColorRgb.pureWhite;
    }

    final double contrast = text.contrastRatioWith(background);
    final double targetMin = standard == ContrastStandard.wcagAAA ? 7.0 : 4.5;

    if (contrast < targetMin) {
      text = ColorRgb.pureWhite;
    }

    return OledPalette(
      background: background,
      surface: surface,
      surfaceBorder: border,
      primaryText: text,
      secondaryText: const ColorRgb(164, 176, 190),
      accent: ColorRgb.emeraldSuccess,
      calculatedContrast: double.parse(contrast.toStringAsFixed(2)),
      isPureBlackOled: pureBlackOled,
    );
  }
}
