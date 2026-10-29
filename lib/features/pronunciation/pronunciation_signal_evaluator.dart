import 'domain/pronunciation_models.dart';

abstract final class PronunciationSignalEvaluator {
  static PronunciationProductionFeedback evaluate({
    required PronunciationSignalCapture capture,
    required String targetToken,
  }) {
    final features = capture.features;
    if (!capture.available || features == null) {
      return PronunciationProductionFeedback(
        signalAvailable: false,
        signalUsable: false,
        timingScore: 0,
        messageAr: _unavailableMessage(capture.reason),
        features: null,
      );
    }

    final expectedMs =
        (280 + targetToken.trim().length * 65).clamp(420, 1500).toInt();
    final observedMs = features.voicedDurationMs;
    final delta = (observedMs - expectedMs).abs();
    final timingScore = (1 - (delta / expectedMs)).clamp(0.0, 1.0).toDouble();

    if (features.rms < .012) {
      return PronunciationProductionFeedback(
        signalAvailable: true,
        signalUsable: false,
        timingScore: timingScore,
        messageAr:
            'الصوت منخفض جدًا. قرّب الهاتف قليلًا وارفع صوتك بشكل طبيعي.',
        features: features,
      );
    }
    if (features.peak >= .985) {
      return PronunciationProductionFeedback(
        signalAvailable: true,
        signalUsable: false,
        timingScore: timingScore,
        messageAr:
            'الإشارة مرتفعة جدًا وقد تكون مشوشة. ابتعد قليلًا عن الميكروفون.',
        features: features,
      );
    }
    if (features.voicedDurationMs < 180) {
      return PronunciationProductionFeedback(
        signalAvailable: true,
        signalUsable: false,
        timingScore: timingScore,
        messageAr:
            'المقطع المنطوق قصير جدًا للتحليل. انطق الكلمة كاملة ثم أعد المحاولة.',
        features: features,
      );
    }
    if (features.zeroCrossingRate > .32) {
      return PronunciationProductionFeedback(
        signalAvailable: true,
        signalUsable: false,
        timingScore: timingScore,
        messageAr: 'هناك ضوضاء أو احتكاك مرتفع في التسجيل. جرّب مكانًا أهدأ.',
        features: features,
      );
    }

    final timingMessage = timingScore >= .72
        ? 'توقيت النطق ضمن نطاق تدريبي مناسب.'
        : observedMs < expectedMs
            ? 'النطق أسرع من النطاق التدريبي المتوقع؛ أبطئ قليلًا.'
            : 'النطق أطول من النطاق التدريبي المتوقع؛ حاول قول الكلمة بوحدة واحدة.';

    return PronunciationProductionFeedback(
      signalAvailable: true,
      signalUsable: true,
      timingScore: timingScore,
      messageAr:
          '$timingMessage هذا فحص محلي لجودة الإشارة والتوقيت، وليس درجة دقة للمخارج أو الفونيمات.',
      features: features,
    );
  }

  static String _unavailableMessage(String? reason) => switch (reason) {
        'microphone_permission_required' =>
          'إذن الميكروفون مطلوب. فعّله ثم أعد المحاولة.',
        'pronunciation_capture_busy' =>
          'هناك تسجيل جارٍ بالفعل. أنهه قبل بدء تسجيل جديد.',
        _ => 'فحص الميكروفون المحلي غير متاح على هذا الجهاز حاليًا. '
            'لن نختلق درجة نطق بديلة.',
      };
}
