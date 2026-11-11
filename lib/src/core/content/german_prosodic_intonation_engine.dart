/// Fundamental pitch movement at clause or sentence termination.
enum IntonationContourType {
  terminalFalling,   // هابط (\) - Aussagesatz, W-Frage, Imperativ
  interrogativeRising, // صاعد (/) - Ja/Nein-Frage, Erstaunen
  progredientSuspended, // معلق (->) - Nebensatz vor Hauptsatz, Aufzählung
}

/// Analysis descriptor of a sentence's melodic pitch accent and intonational contour.
class ProsodicPitchContour {
  final String sentenceText;
  final IntonationContourType contourType;
  final String focusAccentWord;
  final List<double> relativePitchPoints; // Normalized F0 pitch trajectory (0.0 to 1.0)
  final String arabicProsodicExplanation;

  ProsodicPitchContour({
    required this.sentenceText,
    required this.contourType,
    required this.focusAccentWord,
    required this.relativePitchPoints,
    required this.arabicProsodicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'sentence': sentenceText,
        'contour': contourType.name,
        'focus_accent': focusAccentWord,
        'pitch_points': relativePitchPoints,
        'arabic': arabicProsodicExplanation,
      };
}

/// Offline rule engine modeling German prosodic intonation curves (Satzmelodie)
/// for high-fidelity offline pronunciation evaluation and speech synthesis calibration.
class GermanProsodicIntonationEngine {
  static const Set<String> _wQuestionWords = {
    'wer', 'wen', 'wem', 'wessen', 'was', 'wo', 'wohin', 'woher', 'wann', 'warum', 'wie', 'wieso'
  };

  /// Calculate the appropriate intonation contour and pitch points for a German sentence.
  static ProsodicPitchContour computeIntonationContour(String sentence) {
    final clean = sentence.trim();
    if (clean.isEmpty) {
      return ProsodicPitchContour(
        sentenceText: '',
        contourType: IntonationContourType.terminalFalling,
        focusAccentWord: '',
        relativePitchPoints: const [0.5],
        arabicProsodicExplanation: 'نص فارغ',
      );
    }

    final tokens = clean.replaceAll(RegExp(r'[.!?]'), '').split(RegExp(r'\s+'));
    final firstWord = tokens.isNotEmpty ? tokens.first.toLowerCase() : '';
    final lastWord = tokens.isNotEmpty ? tokens.last : '';

    IntonationContourType contour;
    List<double> pitchTrajectory;
    String arabic = '';

    if (clean.endsWith('?')) {
      if (_wQuestionWords.contains(firstWord)) {
        // W-Fragen in standard German have a falling terminal intonation!
        contour = IntonationContourType.terminalFalling;
        pitchTrajectory = [0.8, 0.6, 0.3];
        arabic = 'سؤال استفهامي بأداة (W-Frage): النبرة العامة هابطة في نهاية السؤال (\).';
      } else {
        // Ja/Nein-Fragen have a rising interrogative intonation!
        contour = IntonationContourType.interrogativeRising;
        pitchTrajectory = [0.4, 0.6, 0.95];
        arabic = 'سؤال مغلق (نعم/لا): النبرة صاعدة بشكل حاد في نهاية السؤال (/).';
      }
    } else if (clean.endsWith('!')) {
      // Imperative: strong terminal fall
      contour = IntonationContourType.terminalFalling;
      pitchTrajectory = [0.9, 0.5, 0.2];
      arabic = 'صيغة أمر أو نداء: نبرة حازمة هابطة في النهاية (\).';
    } else if (clean.endsWith(',')) {
      // Suspended progredient clause
      contour = IntonationContourType.progredientSuspended;
      pitchTrajectory = [0.5, 0.6, 0.6];
      arabic = 'جملة معلقة غير مكتملة: النبرة مستوية ومستمرة تمهيداً للجملة التالية (->).';
    } else {
      // Standard declarative statement: terminal falling
      contour = IntonationContourType.terminalFalling;
      pitchTrajectory = [0.5, 0.7, 0.2];
      arabic = 'جملة خبرية تقريرية: نبرة صوتية طبيعية تبدأ بمتوسط ثم ترتفع عند بؤرة المعنى وتهبط في الختام (\).';
    }

    return ProsodicPitchContour(
      sentenceText: clean,
      contourType: contour,
      focusAccentWord: lastWord,
      relativePitchPoints: pitchTrajectory,
      arabicProsodicExplanation: arabic,
    );
  }
}
