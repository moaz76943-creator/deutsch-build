import 'dart:math' as math;

class ResonanceBalanceReport {
  final String phonemeEvaluated;
  final double nasalEnergyRatio; // 0.0 to 1.0
  final double oralEnergyRatio;
  final bool isVelumPositionCorrect;
  final String articulatoryFeedback;

  const ResonanceBalanceReport({
    required this.phonemeEvaluated,
    required this.nasalEnergyRatio,
    required this.oralEnergyRatio,
    required this.isVelumPositionCorrect,
    required this.articulatoryFeedback,
  });

  Map<String, dynamic> toJson() => {
    'phonemeEvaluated': phonemeEvaluated,
    'nasalEnergyRatio': nasalEnergyRatio,
    'oralEnergyRatio': oralEnergyRatio,
    'isVelumPositionCorrect': isVelumPositionCorrect,
    'articulatoryFeedback': articulatoryFeedback,
  };
}

class NasalOralResonanceDetector {
  const NasalOralResonanceDetector();

  /// Analyzes frequency distribution around nasal murmur (250-300Hz) vs oral cavity formants.
  ResonanceBalanceReport evaluateResonance({
    required String targetPhoneme,
    required double lowFreqNasalMurmurDbfs,
    required double midFreqOralFormantDbfs,
  }) {
    final double totalEnergy = math.max(0.01, lowFreqNasalMurmurDbfs.abs() + midFreqOralFormantDbfs.abs());
    final double nasalRatio = (lowFreqNasalMurmurDbfs.abs() / totalEnergy).clamp(0.0, 1.0);
    final double oralRatio = 1.0 - nasalRatio;

    final bool isNasalConsonant = targetPhoneme == 'm' || targetPhoneme == 'n' || targetPhoneme == 'ŋ';
    bool isCorrect;
    String feedback;

    if (isNasalConsonant) {
      isCorrect = nasalRatio >= 0.45;
      feedback = isCorrect
          ? 'Perfekter nasaler Luftstrom! Das Gaumensegel ist optimal gesenkt.'
          : 'Mehr Luft durch die Nase strömen lassen; Gaumensegel entspannen.';
    } else {
      // German pure oral vowels (a, e, i, o, u, ä, ö, ü) must have zero hypernasality
      isCorrect = nasalRatio < 0.35;
      feedback = isCorrect
          ? 'Klarer orales Klangbild ohne störendes Näseln. Sehr gut!'
          : 'Zu starkes Näseln festgestellt. Hebe das Gaumensegel an, um den Nasenraum abzuschließen.';
    }

    return ResonanceBalanceReport(
      phonemeEvaluated: targetPhoneme,
      nasalEnergyRatio: double.parse(nasalRatio.toStringAsFixed(2)),
      oralEnergyRatio: double.parse(oralRatio.toStringAsFixed(2)),
      isVelumPositionCorrect: isCorrect,
      articulatoryFeedback: feedback,
    );
  }
}
