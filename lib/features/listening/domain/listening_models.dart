enum ListeningDrillType { multipleChoice, dictation }

enum ListeningPlaybackSpeed {
  normal(1.0),
  slow(.8);

  const ListeningPlaybackSpeed(this.factor);
  final double factor;
}

final class ListeningOption {
  const ListeningOption({
    required this.id,
    required this.text,
  });

  final String id;
  final String text;
}

final class ListeningDrill {
  ListeningDrill._({
    required this.id,
    required this.type,
    required this.promptArabic,
    required this.audioText,
    required this.languageCode,
    required this.options,
    required this.correctOptionId,
    required this.expectedText,
    required this.targetPhonemes,
    this.conceptId,
  }) {
    _validate();
  }

  factory ListeningDrill.multipleChoice({
    required String id,
    required String promptArabic,
    required String audioText,
    required String languageCode,
    required List<ListeningOption> options,
    required String correctOptionId,
    String? conceptId,
    List<String> targetPhonemes = const <String>[],
  }) {
    return ListeningDrill._(
      id: id,
      type: ListeningDrillType.multipleChoice,
      promptArabic: promptArabic,
      audioText: audioText,
      languageCode: languageCode,
      options: List<ListeningOption>.unmodifiable(options),
      correctOptionId: correctOptionId,
      expectedText: null,
      conceptId: conceptId,
      targetPhonemes: List<String>.unmodifiable(targetPhonemes),
    );
  }

  factory ListeningDrill.dictation({
    required String id,
    required String promptArabic,
    required String audioText,
    required String languageCode,
    required String expectedText,
    String? conceptId,
    List<String> targetPhonemes = const <String>[],
  }) {
    return ListeningDrill._(
      id: id,
      type: ListeningDrillType.dictation,
      promptArabic: promptArabic,
      audioText: audioText,
      languageCode: languageCode,
      options: const <ListeningOption>[],
      correctOptionId: null,
      expectedText: expectedText,
      conceptId: conceptId,
      targetPhonemes: List<String>.unmodifiable(targetPhonemes),
    );
  }

  final String id;
  final ListeningDrillType type;
  final String promptArabic;
  final String audioText;
  final String languageCode;
  final List<ListeningOption> options;
  final String? correctOptionId;
  final String? expectedText;
  final String? conceptId;
  final List<String> targetPhonemes;

  void _validate() {
    if (id.trim().isEmpty ||
        promptArabic.trim().isEmpty ||
        audioText.trim().isEmpty ||
        languageCode.trim().isEmpty) {
      throw ArgumentError('Listening drill text fields must not be empty.');
    }

    if (type == ListeningDrillType.multipleChoice) {
      if (options.length < 2) {
        throw ArgumentError(
          'Multiple-choice listening drills require at least two options.',
        );
      }
      final ids = options.map((option) => option.id).toSet();
      if (ids.length != options.length ||
          !ids.contains(correctOptionId) ||
          options.any(
            (option) => option.id.trim().isEmpty || option.text.trim().isEmpty,
          )) {
        throw ArgumentError('Listening drill options are invalid.');
      }
      return;
    }

    if (expectedText == null || expectedText!.trim().isEmpty) {
      throw ArgumentError('Dictation drills require expected text.');
    }
  }
}

final class ListeningAnswerResult {
  const ListeningAnswerResult({
    required this.correct,
    required this.pointsAwarded,
    required this.normalizedExpected,
    required this.normalizedAnswer,
  });

  final bool correct;
  final int pointsAwarded;
  final String normalizedExpected;
  final String normalizedAnswer;
}

final class PronunciationPhonemeMatch {
  const PronunciationPhonemeMatch({
    required this.target,
    required this.observed,
    required this.matched,
  });

  final String target;
  final String? observed;
  final bool matched;
}

final class PronunciationFeedback {
  const PronunciationFeedback({
    required this.signalAvailable,
    required this.accuracy,
    required this.textAccuracy,
    required this.phonemeMatches,
    required this.messageArabic,
    this.recognizedText,
  });

  final bool signalAvailable;

  /// Null unless a recorder/analyzer supplied measured phoneme observations.
  final double? accuracy;

  /// Optional normalized text-recognition similarity, distinct from phoneme accuracy.
  final double? textAccuracy;
  final List<PronunciationPhonemeMatch> phonemeMatches;
  final String messageArabic;
  final String? recognizedText;

  bool get phonemeAccuracyAvailable =>
      accuracy != null && phonemeMatches.isNotEmpty;
}
