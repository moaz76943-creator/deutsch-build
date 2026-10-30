import 'dart:math' as math;

class VowelAcousticTarget {
  final String ipaSymbol;
  final double targetF1Hz; // Tongue height (inverse)
  final double targetF2Hz; // Tongue frontness/backness
  final double toleranceHz;

  const VowelAcousticTarget({
    required this.ipaSymbol,
    required this.targetF1Hz,
    required this.targetF2Hz,
    this.toleranceHz = 120.0,
  });
}

class VowelCalibrationReport {
  final String vowel;
  final double measuredF1;
  final double measuredF2;
  final double euclideanDistance;
  final bool isWithinNativeRange;
  final String correctiveAdvice;

  const VowelCalibrationReport({
    required this.vowel,
    required this.measuredF1,
    required this.measuredF2,
    required this.euclideanDistance,
    required this.isWithinNativeRange,
    required this.correctiveAdvice,
  });
}

class VowelFormantCalibrator {
  static const Map<String, VowelAcousticTarget> germanVowelTargets = {
    'i:': VowelAcousticTarget(ipaSymbol: 'i:', targetF1Hz: 280, targetF2Hz: 2250), // "bieten"
    'y:': VowelAcousticTarget(ipaSymbol: 'y:', targetF1Hz: 290, targetF2Hz: 2000), // "Bühne"
    'e:': VowelAcousticTarget(ipaSymbol: 'e:', targetF1Hz: 390, targetF2Hz: 2150), // "Beet"
    'ø:': VowelAcousticTarget(ipaSymbol: 'ø:', targetF1Hz: 400, targetF2Hz: 1650), // "böse"
    'u:': VowelAcousticTarget(ipaSymbol: 'u:', targetF1Hz: 320, targetF2Hz: 800),  // "Mut"
    'a:': VowelAcousticTarget(ipaSymbol: 'a:', targetF1Hz: 750, targetF2Hz: 1250), // "Bahn"
  };

  const VowelFormantCalibrator();

  VowelCalibrationReport calibrateVowel({
    required String vowelKey,
    required double measuredF1,
    required double measuredF2,
  }) {
    final target = germanVowelTargets[vowelKey] ?? germanVowelTargets['a:']!;
    final double dF1 = measuredF1 - target.targetF1Hz;
    final double dF2 = measuredF2 - target.targetF2Hz;
    final double distance = math.sqrt(dF1 * dF1 + dF2 * dF2);

    final bool isNative = distance <= target.toleranceHz;
    String advice;

    if (isNative) {
      advice = 'Perfekte Aussprache! Deine Zungenposition und Lippenform treffen den nativen Bereich.';
    } else if (dF2 < -150) {
      advice = 'Zunge weiter nach vorne schieben und Lippen runder spitzen.';
    } else if (dF1 > 120) {
      advice = 'Kiefer etwas mehr schließen, Zunge höher ansetzen.';
    } else {
      advice = 'Zungenhöhe und Mundöffnung leicht anpassen für mehr Resonanz.';
    }

    return VowelCalibrationReport(
      vowel: target.ipaSymbol,
      measuredF1: measuredF1,
      measuredF2: measuredF2,
      euclideanDistance: double.parse(distance.toStringAsFixed(1)),
      isWithinNativeRange: isNative,
      correctiveAdvice: advice,
    );
  }
}
