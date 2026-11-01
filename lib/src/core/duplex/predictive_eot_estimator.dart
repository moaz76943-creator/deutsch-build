enum TurnCompletionAction {
  yieldTurnToTutor, // Learner finished speaking; tutor should take turn immediately
  holdFloorAwaitContinuation, // Learner paused mid-thought; keep listening
}

enum EoTCueType {
  prosodicTerminalFall, // Clear falling terminal pitch contour
  prosodicTerminalRise, // Final question pitch rise
  danglingSyntacticConnector, // Sentence ended on preposition/conjunction (holds turn)
  hesitationProlongation, // Trailing "umm / yani" sound
  standardSilenceTimeout, // Pure silence fallback
}

class EoTPredictionResult {
  final bool isTurnCompleted;
  final double completionProbability; // [0.0 to 1.0]
  final TurnCompletionAction action;
  final EoTCueType dominantCue;
  final int silenceDurationMs;
  final String diagnosticReasonAr;

  const EoTPredictionResult({
    required this.isTurnCompleted,
    required this.completionProbability,
    required this.action,
    required this.dominantCue,
    required this.silenceDurationMs,
    required this.diagnosticReasonAr,
  });
}

/// Sovereign on-device Predictive End-of-Turn (EoT) Neural Estimator.
/// Replaces legacy sluggish silence timeouts (which leave awkward 700ms gaps)
/// by evaluating syntactic closure and prosodic pitch trends within <=150ms.
class PredictiveEotEstimator {
  final int fastTimeoutThresholdMs; // e.g. 150ms when syntax & prosody signal closure
  final int extendedHoldThresholdMs; // e.g. 750ms when dangling connector detected

  const PredictiveEotEstimator({
    this.fastTimeoutThresholdMs = 150,
    this.extendedHoldThresholdMs = 750,
  });

  /// Multilingual trailing connectors that indicate thought continuation
  static final Set<String> _continuationWords = {
    'و', 'ثم', 'أو', 'لكن', 'في', 'من', 'على', 'إلى', 'أن', 'لأن',
    'and', 'but', 'or', 'because', 'that', 'with', 'at', 'in', 'so',
    've', 'veya', 'ama', 'çünkü', 'ile', 'için', 'de', 'da',
    'dan', 'atau', 'tetapi', 'karena', 'bahwa', 'dengan',
  };

  /// Evaluates whether the current conversational turn is complete.
  EoTPredictionResult evaluateTurnCompletion({
    required String recentPartialTranscript,
    required double terminalPitchSlope, // Negative indicates falling pitch; Positive indicates rising
    required int currentSilenceDurationMs,
  }) {
    final tokens = recentPartialTranscript
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return const EoTPredictionResult(
        isTurnCompleted: false,
        completionProbability: 0.0,
        action: TurnCompletionAction.holdFloorAwaitContinuation,
        dominantCue: EoTCueType.standardSilenceTimeout,
        silenceDurationMs: 0,
        diagnosticReasonAr: 'لا توجد كلمات مرصودة.',
      );
    }

    final lastToken = tokens.last.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');
    final hasDanglingConnector = _continuationWords.contains(lastToken);

    // 1. If ending with an unfinished connector: hold floor even with moderate silence
    if (hasDanglingConnector) {
      final isTimeout = currentSilenceDurationMs >= extendedHoldThresholdMs;
      return EoTPredictionResult(
        isTurnCompleted: isTimeout,
        completionProbability: isTimeout ? 0.65 : 0.20,
        action: isTimeout ? TurnCompletionAction.yieldTurnToTutor : TurnCompletionAction.holdFloorAwaitContinuation,
        dominantCue: EoTCueType.danglingSyntacticConnector,
        silenceDurationMs: currentSilenceDurationMs,
        diagnosticReasonAr: isTimeout
            ? 'انقضاء مهلة الانتظار الموسعة بعد أداة عطف/ربط.'
            : 'الجملة انتهت برابط نحوي ($lastToken)؛ استمرار الاستماع لإتاحة إكمال الفكرة.',
      );
    }

    // 2. Syntactic closure + strong terminal pitch fall -> fast-track turn completion
    if (terminalPitchSlope < -12.0 && currentSilenceDurationMs >= fastTimeoutThresholdMs) {
      return EoTPredictionResult(
        isTurnCompleted: true,
        completionProbability: 0.95,
        action: TurnCompletionAction.yieldTurnToTutor,
        dominantCue: EoTCueType.prosodicTerminalFall,
        silenceDurationMs: currentSilenceDurationMs,
        diagnosticReasonAr: 'اكتمال تركيبي مقترن بهبوط نغمي حاسم؛ تسليم دفة الحوار فوراً.',
      );
    }

    // 3. Question terminal rise -> yield turn after short silence
    if (terminalPitchSlope > 15.0 && currentSilenceDurationMs >= fastTimeoutThresholdMs) {
      return EoTPredictionResult(
        isTurnCompleted: true,
        completionProbability: 0.92,
        action: TurnCompletionAction.yieldTurnToTutor,
        dominantCue: EoTCueType.prosodicTerminalRise,
        silenceDurationMs: currentSilenceDurationMs,
        diagnosticReasonAr: 'صعود نغمي استفهامي بنهاية الجملة؛ تسليم الدور للمعلم للإجابة.',
      );
    }

    // 4. Fallback silence check
    final isGeneralTimeout = currentSilenceDurationMs >= 450;
    return EoTPredictionResult(
      isTurnCompleted: isGeneralTimeout,
      completionProbability: isGeneralTimeout ? 0.80 : 0.40,
      action: isGeneralTimeout ? TurnCompletionAction.yieldTurnToTutor : TurnCompletionAction.holdFloorAwaitContinuation,
      dominantCue: EoTCueType.standardSilenceTimeout,
      silenceDurationMs: currentSilenceDurationMs,
      diagnosticReasonAr: isGeneralTimeout ? 'اكتمال الدور عبر توقف الصمت القياسي.' : 'توقف عابر قصير قيد الملاحظة.',
    );
  }
}
