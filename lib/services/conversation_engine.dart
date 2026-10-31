import '../language/language_exercise_strategy.dart';
import '../language/language_text_normalizer.dart';
import '../models/conversation.dart';

class ConversationEngine {
  final LanguageExerciseStrategy exerciseStrategy;
  final LanguageTextNormalizer textNormalizer;
  const ConversationEngine({
    required this.exerciseStrategy,
    required this.textNormalizer,
  });

  List<ConversationScenario> get scenarios =>
      exerciseStrategy.conversationScenarios;

  ConversationScore score(ConversationTurn turn, String transcript) {
    final answer = textNormalizer.answer(transcript);
    final accepted = turn.expected.map(textNormalizer.answer).toSet();
    if (answer.isEmpty)
      return ConversationScore(
        value: 0,
        correct: false,
        matchedKeywords: const [],
        missingKeywords: turn.keywords
            .map(textNormalizer.answer)
            .where((x) => x.isNotEmpty)
            .toList(),
      );
    if (accepted.contains(answer))
      return ConversationScore(
        value: 100,
        correct: true,
        matchedKeywords: turn.keywords.map(textNormalizer.answer).toList(),
        missingKeywords: const [],
      );
    final matched = <String>[];
    final missing = <String>[];
    final normalizedKeys = turn.keywords
        .map(textNormalizer.answer)
        .where((x) => x.isNotEmpty)
        .toList();
    for (final key in normalizedKeys) {
      if (_tokensContainSimilar(answer, key))
        matched.add(key);
      else
        missing.add(key);
    }
    final coverage =
        normalizedKeys.isEmpty ? 0.0 : matched.length / normalizedKeys.length;
    final order = _orderScore(answer, matched);
    final value = (coverage * 80 + order * 20).round().clamp(0, 99);
    return ConversationScore(
      value: value,
      correct: coverage >= .67 && order >= .50,
      matchedKeywords: matched,
      missingKeywords: missing,
    );
  }

  static bool _tokensContainSimilar(String text, String token) {
    final tokens = text.split(' ').where((x) => x.isNotEmpty);
    for (final candidate in tokens) {
      if (_tokenSimilarity(candidate, token) >= .80) return true;
    }
    return false;
  }

  static double _tokenSimilarity(String a, String b) {
    if (a == b) return 1;
    if (a.length < 4 || b.length < 4) return 0;
    final limit = a.length < b.length ? a.length : b.length;
    var common = 0;
    while (common < limit && a[common] == b[common]) common++;
    return common / (a.length > b.length ? a.length : b.length);
  }

  static double _orderScore(String text, List<String> matched) {
    if (matched.length <= 1) return 1;
    final tokens = text.split(' ').where((x) => x.isNotEmpty).toList();
    var cursor = -1;
    var ordered = 0;
    for (final key in matched) {
      var found = -1;
      for (var i = cursor + 1; i < tokens.length; i++) {
        if (_tokenSimilarity(tokens[i], key) >= .80) {
          found = i;
          break;
        }
      }
      if (found >= 0) {
        ordered++;
        cursor = found;
      }
    }
    return ordered / matched.length;
  }
}
