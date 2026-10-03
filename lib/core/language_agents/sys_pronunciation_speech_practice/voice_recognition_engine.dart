import '../../infrastructure/audio/speech_to_text_engine.dart';
import 'speech_models.dart';

final class VoiceRecognitionEngine {
  const VoiceRecognitionEngine();

  SpeechComparison compare({
    required SpeechPracticePrompt prompt,
    required String recognizedText,
  }) {
    if (!prompt.isValid) {
      return SpeechComparison(
        recognizedText: recognizedText,
        matchedTarget: prompt.text,
        similarity: 0,
        isExact: false,
        isAccepted: false,
        feedbackCode: 'invalid_prompt',
      );
    }

    final recognized = _normalize(recognizedText);
    final targets = <String>[prompt.text, ...prompt.acceptedForms];

    var bestTarget = prompt.text;
    var bestScore = 0.0;
    var exact = false;

    for (final target in targets) {
      final normalizedTarget = _normalize(target);
      final isExactMatch =
          recognized.isNotEmpty && recognized == normalizedTarget;
      final score = isExactMatch
          ? 1.0
          : _similarity(recognized, normalizedTarget);
      if (score > bestScore || isExactMatch) {
        bestScore = score;
        bestTarget = target;
        exact = isExactMatch;
      }
      if (isExactMatch) break;
    }

    final accepted = exact || bestScore >= 0.84;
    final feedback = exact
        ? 'exact_match'
        : bestScore >= 0.84
            ? 'close_match'
            : bestScore >= 0.62
                ? 'needs_refinement'
                : 'retry_required';

    return SpeechComparison(
      recognizedText: recognizedText.trim(),
      matchedTarget: bestTarget,
      similarity: bestScore.clamp(0.0, 1.0).toDouble(),
      isExact: exact,
      isAccepted: accepted,
      feedbackCode: feedback,
    );
  }

  SpeechRecognitionSession createSession(SpeechPracticePrompt prompt) =>
      SpeechRecognitionSession(
        prompt: prompt,
        engine: SpeechToTextEngine(localeId: prompt.localeId),
        comparator: this,
      );

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp(r'[.,!?;:،؟“”„()]'), ' ')
      .replaceAll("'", ' ')
      .replaceAll('"', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static double _similarity(String left, String right) {
    if (left == right && left.isNotEmpty) return 1;
    if (left.isEmpty || right.isEmpty) return 0;

    final distance = _levenshtein(left, right);
    final longest = left.length > right.length ? left.length : right.length;
    return 1 - (distance / longest);
  }

  static int _levenshtein(String left, String right) {
    var previous = List<int>.generate(right.length + 1, (i) => i);
    for (var i = 1; i <= left.length; i++) {
      final current = List<int>.filled(right.length + 1, 0);
      current[0] = i;
      for (var j = 1; j <= right.length; j++) {
        final substitutionCost =
            left.codeUnitAt(i - 1) == right.codeUnitAt(j - 1) ? 0 : 1;
        final deletion = previous[j] + 1;
        final insertion = current[j - 1] + 1;
        final substitution = previous[j - 1] + substitutionCost;
        current[j] = _min3(deletion, insertion, substitution);
      }
      previous = current;
    }
    return previous[right.length];
  }

  static int _min3(int a, int b, int c) {
    var result = a < b ? a : b;
    if (c < result) result = c;
    return result;
  }
}

final class SpeechRecognitionSession {
  SpeechRecognitionSession({
    required this.prompt,
    required SpeechToTextEngine engine,
    required VoiceRecognitionEngine comparator,
  })  : _engine = engine,
        _comparator = comparator;

  final SpeechPracticePrompt prompt;
  final SpeechToTextEngine _engine;
  final VoiceRecognitionEngine _comparator;

  Future<bool> initialize() => _engine.initialize();

  Future<bool> listen({
    required void Function(SpeechRecognitionSnapshot snapshot) onResult,
  }) =>
      _engine.listen(
        onResult: (result) {
          onResult(
            SpeechRecognitionSnapshot(
              text: result.recognizedWords,
              isFinal: result.finalResult,
              evaluation: _comparator.compare(
                prompt: prompt,
                recognizedText: result.recognizedWords,
              ),
            ),
          );
        },
      );

  Future<void> stop() => _engine.stop();

  bool get isListening => _engine.isListening;

  void dispose() => _engine.dispose();
}
