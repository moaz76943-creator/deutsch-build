/// Categorical pitch tone in Mandarin and Southeast Asian tonal languages.
enum MandarinTone {
  firstFlatHigh,  // 55 (mā)
  secondRising,   // 35 (má)
  thirdDipping,   // 214 (mǎ - fall then rise)
  fourthFalling,  // 51 (mà)
  neutralLight,   // (ma)
}

/// Evaluation result comparing spoken tone contour against target lexical tone.
class ToneRecognitionResult {
  final MandarinTone detectedTone;
  final MandarinTone expectedTone;
  final bool isToneCorrect;
  final double confidenceScore;
  final String pedagogicalAdvice;

  const ToneRecognitionResult({
    required this.detectedTone,
    required this.expectedTone,
    required this.isToneCorrect,
    required this.confidenceScore,
    required this.pedagogicalAdvice,
  });
}

/// Analyzes normalized fundamental frequency F0 trajectory to classify tones.
class TonalContourRecognitionEngine {
  const TonalContourRecognitionEngine();

  /// Classifies pitch contour points into one of the four Mandarin tones.
  ToneRecognitionResult classifyMandarinTone({
    required List<double> pitchTrackHz,
    required MandarinTone expectedTone,
  }) {
    if (pitchTrackHz.length < 3) {
      return ToneRecognitionResult(
        detectedTone: MandarinTone.neutralLight,
        expectedTone: expectedTone,
        isToneCorrect: false,
        confidenceScore: 0.0,
        pedagogicalAdvice: 'المقطع الصوتي قصير جداً لتحليل النغمة.',
      );
    }

    final startPitch = pitchTrackHz.first;
    final midPitch = pitchTrackHz[pitchTrackHz.length ~/ 2];
    final endPitch = pitchTrackHz.last;

    final overallSlope = endPitch - startPitch;
    final midDip = midPitch < min(startPitch, endPitch) - 15.0;

    MandarinTone detected;
    double confidence = 0.90;

    if (midDip) {
      detected = MandarinTone.thirdDipping; // 214 Fall-Rise
    } else if (overallSlope > 25.0) {
      detected = MandarinTone.secondRising; // 35 Rising
    } else if (overallSlope < -25.0) {
      detected = MandarinTone.fourthFalling; // 51 Falling
    } else {
      detected = MandarinTone.firstFlatHigh; // 55 Flat
    }

    final isCorrect = detected == expectedTone;
    String advice;

    if (isCorrect) {
      advice = 'نغمة دقيقة تماماً!';
    } else {
      switch (expectedTone) {
        case MandarinTone.firstFlatHigh:
          advice = 'المطلوب نغمة أولى: حافظ على استقرار الصوت ونبرة حادة مسطحة وثابتة (High Flat).';
          break;
        case MandarinTone.secondRising:
          advice = 'المطلوب نغمة ثانية: ارفع نبرة الصوت لأعلى مثل طرح سؤال تعجبي (Rising).';
          break;
        case MandarinTone.thirdDipping:
          advice = 'المطلوب نغمة ثالثة: اخفض الصوت في الوسط ثم ارفعه مجدداً (Fall-Rise).';
          break;
        case MandarinTone.fourthFalling:
          advice = 'المطلوب نغمة رابعة: اهبط بالصوت بقوة وسرعة كأنك تصدر أمراً حازماً (Sharp Drop).';
          break;
        case MandarinTone.neutralLight:
          advice = 'المطلوب نغمة محايدة خفيفة وسريعة دون مد.';
          break;
      }
    }

    return ToneRecognitionResult(
      detectedTone: detected,
      expectedTone: expectedTone,
      isToneCorrect: isCorrect,
      confidenceScore: confidence,
      pedagogicalAdvice: advice,
    );
  }
}
