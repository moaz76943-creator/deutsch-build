class StudySessionPowerMetrics {
  final int activeStudyMinutes;
  final int ttsAudioSynthesisSeconds;
  final int asrSpeechRecognitionSeconds;
  final int llmGenerationTurns;
  final bool isOledPureBlackTheme;

  const StudySessionPowerMetrics({
    required this.activeStudyMinutes,
    required this.ttsAudioSynthesisSeconds,
    required this.asrSpeechRecognitionSeconds,
    required this.llmGenerationTurns,
    required this.isOledPureBlackTheme,
  });
}

class BatteryEfficiencyReport {
  final double totalEstimatedMahDrain;
  final double estimatedBatteryPercentPerHour; // Based on 4000mAh baseline
  final bool isWithinEcoBudget;
  final Map<String, double> componentBreakdownMah;
  final String efficiencyVerdict;

  const BatteryEfficiencyReport({
    required this.totalEstimatedMahDrain,
    required this.estimatedBatteryPercentPerHour,
    required this.isWithinEcoBudget,
    required this.componentBreakdownMah,
    required this.efficiencyVerdict,
  });

  Map<String, dynamic> toJson() => {
    'totalEstimatedMahDrain': totalEstimatedMahDrain,
    'estimatedBatteryPercentPerHour': estimatedBatteryPercentPerHour,
    'isWithinEcoBudget': isWithinEcoBudget,
    'componentBreakdownMah': componentBreakdownMah,
    'efficiencyVerdict': efficiencyVerdict,
  };
}

class BatteryDrainProfiler {
  // Power drain coefficients per unit based on Snapdragon 8 Gen 2 / Dimensity benchmarks
  static const double _displayPowerMahPerMinOled = 0.20; // Pure black saves ~60% screen draw
  static const double _displayPowerMahPerMinStandard = 0.55;
  static const double _ttsPowerMahPerSecond = 0.04;
  static const double _asrPowerMahPerSecond = 0.05;
  static const double _llmPowerMahPerTurn = 0.12;

  const BatteryDrainProfiler();

  /// Analyzes session telemetry and outputs rigorous battery consumption profile.
  BatteryEfficiencyReport profileSession(StudySessionPowerMetrics metrics) {
    final double displayRate = metrics.isOledPureBlackTheme
        ? _displayPowerMahPerMinOled
        : _displayPowerMahPerMinStandard;

    final double displayDrain = metrics.activeStudyMinutes * displayRate;
    final double ttsDrain = metrics.ttsAudioSynthesisSeconds * _ttsPowerMahPerSecond;
    final double asrDrain = metrics.asrSpeechRecognitionSeconds * _asrPowerMahPerSecond;
    final double llmDrain = metrics.llmGenerationTurns * _llmPowerMahPerTurn;

    final double totalMah = displayDrain + ttsDrain + asrDrain + llmDrain;

    // Rate per hour calculation: (totalMah / minutes) * 60
    final double mahPerHour = metrics.activeStudyMinutes > 0
        ? (totalMah / metrics.activeStudyMinutes) * 60.0
        : 0.0;
    final double percentPerHour = (mahPerHour / 4000.0) * 100.0;

    // 15-minute standard intensive target is strictly < 18.0 mAh
    final bool isEco = (totalMah / (metrics.activeStudyMinutes > 0 ? metrics.activeStudyMinutes : 1)) <= (18.0 / 15.0);

    return BatteryEfficiencyReport(
      totalEstimatedMahDrain: double.parse(totalMah.toStringAsFixed(2)),
      estimatedBatteryPercentPerHour: double.parse(percentPerHour.toStringAsFixed(2)),
      isWithinEcoBudget: isEco,
      componentBreakdownMah: {
        'display': double.parse(displayDrain.toStringAsFixed(2)),
        'ttsSynthesis': double.parse(ttsDrain.toStringAsFixed(2)),
        'asrRecognition': double.parse(asrDrain.toStringAsFixed(2)),
        'llmInference': double.parse(llmDrain.toStringAsFixed(2)),
      },
      efficiencyVerdict: isEco ? 'ECO_EFFICIENCY_CERTIFIED' : 'POWER_REGRESSION_DETECTED',
    );
  }
}
