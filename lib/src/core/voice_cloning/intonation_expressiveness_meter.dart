import 'dart:math' as math;

enum GermanSentenceType {
  declarativeStatement, // Falling pitch at the end
  whQuestion,           // Falling pitch at the end ("Wo wohnst du?")
  yesNoQuestion,        // Rising pitch at the end ("Kommst du mit?")
}

enum PitchDirection {
  fallingCadence,
  risingTerminal,
  monotoneFlat,
}

class IntonationExpressivenessReport {
  final GermanSentenceType sentenceType;
  final PitchDirection detectedDirection;
  final double pitchRangeSemitones;
  final double expressivenessScore; // 0.0 to 100.0%
  final bool isIntonationCorrect;
  final String prosodicAdvice;

  const IntonationExpressivenessReport({
    required this.sentenceType,
    required this.detectedDirection,
    required this.pitchRangeSemitones,
    required this.expressivenessScore,
    required this.isIntonationCorrect,
    required this.prosodicAdvice,
  });

  Map<String, dynamic> toJson() => {
    'sentenceType': sentenceType.name,
    'detectedDirection': detectedDirection.name,
    'pitchRangeSemitones': pitchRangeSemitones,
    'expressivenessScore': expressivenessScore,
    'isIntonationCorrect': isIntonationCorrect,
    'prosodicAdvice': prosodicAdvice,
  };
}

class IntonationExpressivenessMeter {
  const IntonationExpressivenessMeter();

  /// Analyzes F0 pitch trajectory samples across a sentence to assess German melody.
  IntonationExpressivenessReport evaluateIntonation({
    required List<double> f0TrajectoryHz,
    required GermanSentenceType sentenceType,
  }) {
    if (f0TrajectoryHz.length < 3) {
      return IntonationExpressivenessReport(
        sentenceType: sentenceType,
        detectedDirection: PitchDirection.monotoneFlat,
        pitchRangeSemitones: 0.0,
        expressivenessScore: 0.0,
        isIntonationCorrect: false,
        prosodicAdvice: 'Zu kurze Aufnahme für die Melodieanalyse.',
      );
    }

    final double f0Min = f0TrajectoryHz.reduce(math.min);
    final double f0Max = f0TrajectoryHz.reduce(math.max);
    final double pitchRangeSemitones = f0Min > 0
        ? 12.0 * (math.log(f0Max / f0Min) / math.ln2)
        : 0.0;

    // Compare start vs terminal slope
    final double initialPitch = f0TrajectoryHz.first;
    final double finalPitch = f0TrajectoryHz.last;
    final double terminalDeltaHz = finalPitch - initialPitch;

    PitchDirection direction;
    if (terminalDeltaHz > 15.0) {
      direction = PitchDirection.risingTerminal;
    } else if (terminalDeltaHz < -15.0) {
      direction = PitchDirection.fallingCadence;
    } else {
      direction = PitchDirection.monotoneFlat;
    }

    bool isCorrect = false;
    String advice;

    if (sentenceType == GermanSentenceType.yesNoQuestion) {
      isCorrect = direction == PitchDirection.risingTerminal;
      advice = isCorrect
          ? 'Hervorragende Frage-Melodie! Die Stimme steigt am Satzende klar an.'
          : 'Bei Ja/Nein-Fragen muss die Tonhöhe am Satzende deutlich nach oben steigen (Frage-Intonation).';
    } else {
      isCorrect = direction == PitchDirection.fallingCadence;
      advice = isCorrect
          ? 'Natürliche deutsche Satzmelodie mit sauber absinkender Endkadenz.'
          : 'Aussagesätze und W-Fragen verlangen im Deutschen ein Absenken der Stimme am Satzende.';
    }

    final double score = (isCorrect ? 70.0 : 30.0) + (pitchRangeSemitones.clamp(2.0, 8.0) / 8.0 * 30.0);

    return IntonationExpressivenessReport(
      sentenceType: sentenceType,
      detectedDirection: direction,
      pitchRangeSemitones: double.parse(pitchRangeSemitones.toStringAsFixed(1)),
      expressivenessScore: double.parse(score.toStringAsFixed(1)),
      isIntonationCorrect: isCorrect,
      prosodicAdvice: advice,
    );
  }
}
