import 'dart:convert';

class VerifiedExercise {
  const VerifiedExercise({
    required this.conceptId,
    required this.languageCode,
    required this.prompt,
    required this.correctAnswer,
    required this.distractors,
  });

  final String conceptId;
  final String languageCode;
  final String prompt;
  final String correctAnswer;
  final List<String> distractors;

  factory VerifiedExercise.fromPackRow(
    Map<String, dynamic> row, {
    required String conceptId,
    required String languageCode,
  }) {
    final prompt = row['prompt'];
    final correct = row['correct_answer'];
    final rawDistractors = row['distractors_json'];
    if (prompt is! String ||
        correct is! String ||
        rawDistractors is! String ||
        prompt.trim().isEmpty ||
        correct.trim().isEmpty) {
      throw const FormatException('Malformed verified exercise');
    }

    final decoded = jsonDecode(rawDistractors);
    if (decoded is! List || decoded.any((item) => item is! String)) {
      throw const FormatException('Malformed verified exercise distractors');
    }

    final distractors = <String>[];
    for (final item in decoded.cast<String>()) {
      final value = item.trim();
      if (value.isEmpty ||
          value == correct.trim() ||
          distractors.contains(value)) {
        continue;
      }
      distractors.add(value);
    }

    return VerifiedExercise(
      conceptId: conceptId.trim(),
      languageCode: languageCode.trim().toLowerCase().replaceAll('_', '-'),
      prompt: prompt.trim(),
      correctAnswer: correct.trim(),
      distractors: List<String>.unmodifiable(distractors),
    );
  }

  String get stableKey =>
      languageCode + '::' + conceptId + '::' + _stableSeed(prompt).toString();

  List<String> get options {
    final values = <String>[...distractors];
    final index = _stableSeed(prompt + correctAnswer) % (values.length + 1);
    values.insert(index, correctAnswer);
    return List<String>.unmodifiable(values);
  }

  static int _stableSeed(String value) {
    var hash = 17;
    for (final codeUnit in value.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}

typedef VerifiedExerciseLoader = Future<List<Map<String, dynamic>>> Function(
  String conceptId,
  String languageCode,
);
