import '../../../core/content_contract.dart';

enum PronunciationContrastKind {
  vowelLength,
  roundedVowel,
  vowelFronting,
  ichAch,
}

final class PronunciationContrast {
  const PronunciationContrast({
    required this.id,
    required this.kind,
    required this.leftToken,
    required this.rightToken,
    required this.titleAr,
    required this.coachingAr,
  });

  final String id;
  final PronunciationContrastKind kind;
  final String leftToken;
  final String rightToken;
  final String titleAr;
  final String coachingAr;
}

final class PronunciationTarget<T extends LearningContent> {
  const PronunciationTarget({
    required this.item,
    required this.token,
    required this.isLeft,
  });

  final T item;
  final String token;
  final bool isLeft;
}

final class PronunciationTrial<T extends LearningContent> {
  const PronunciationTrial({
    required this.contrast,
    required this.target,
    required this.leftItem,
    required this.rightItem,
    required this.round,
  });

  final PronunciationContrast contrast;
  final PronunciationTarget<T> target;
  final T leftItem;
  final T rightItem;
  final int round;

  List<String> get options => <String>[contrast.leftToken, contrast.rightToken];
}

final class PronunciationPerceptionResult {
  const PronunciationPerceptionResult({
    required this.correct,
    required this.expectedToken,
    required this.selectedToken,
    required this.feedbackAr,
  });

  final bool correct;
  final String expectedToken;
  final String selectedToken;
  final String feedbackAr;
}

final class PronunciationSignalFeatures {
  const PronunciationSignalFeatures({
    required this.captureDurationMs,
    required this.voicedDurationMs,
    required this.rms,
    required this.peak,
    required this.zeroCrossingRate,
  });

  final int captureDurationMs;
  final int voicedDurationMs;
  final double rms;
  final double peak;
  final double zeroCrossingRate;

  factory PronunciationSignalFeatures.fromMap(Map<Object?, Object?> map) {
    int asInt(String key) {
      final value = map[key];
      return value is num ? value.toInt() : 0;
    }

    double asDouble(String key) {
      final value = map[key];
      return value is num ? value.toDouble() : 0;
    }

    return PronunciationSignalFeatures(
      captureDurationMs: asInt('captureDurationMs').clamp(0, 5000).toInt(),
      voicedDurationMs: asInt('voicedDurationMs').clamp(0, 5000).toInt(),
      rms: asDouble('rms').clamp(0.0, 1.0).toDouble(),
      peak: asDouble('peak').clamp(0.0, 1.0).toDouble(),
      zeroCrossingRate: asDouble('zeroCrossingRate').clamp(0.0, 1.0).toDouble(),
    );
  }
}

final class PronunciationSignalCapture {
  const PronunciationSignalCapture.available(this.features)
      : available = true,
        reason = null;

  const PronunciationSignalCapture.unavailable(this.reason)
      : available = false,
        features = null;

  final bool available;
  final String? reason;
  final PronunciationSignalFeatures? features;
}

final class PronunciationProductionFeedback {
  const PronunciationProductionFeedback({
    required this.signalAvailable,
    required this.signalUsable,
    required this.timingScore,
    required this.messageAr,
    required this.features,
  });

  final bool signalAvailable;
  final bool signalUsable;
  final double timingScore;
  final String messageAr;
  final PronunciationSignalFeatures? features;

  bool get phonemeAccuracyAvailable => false;
}

final class PronunciationConfusionStat {
  const PronunciationConfusionStat({
    required this.contrastId,
    required this.attempts,
    required this.mistakes,
  });

  final String contrastId;
  final int attempts;
  final int mistakes;

  double get errorRate => attempts == 0 ? 0 : mistakes / attempts;
}
