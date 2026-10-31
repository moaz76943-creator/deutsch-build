import 'dart:math';

import '../domain/grammar_drill_models.dart';

abstract final class SentenceTokenBank {
  static List<GrammarToken> shuffled(
    SentenceReorderExercise exercise, {
    int? seed,
  }) {
    if (exercise.tokens.length < 2) {
      return List<GrammarToken>.unmodifiable(exercise.tokens);
    }

    final resolvedSeed = seed ?? _stableSeed(exercise.id);
    final result = List<GrammarToken>.of(exercise.tokens)
      ..shuffle(Random(resolvedSeed));

    if (_matchesCanonicalOrder(result, exercise.correctTokenIds)) {
      final first = result.removeAt(0);
      result.add(first);
    }
    return List<GrammarToken>.unmodifiable(result);
  }

  static int _stableSeed(String value) {
    var hash = 17;
    for (final unit in value.codeUnits) {
      hash = ((hash * 37) ^ unit) & 0x7fffffff;
    }
    return hash;
  }

  static bool _matchesCanonicalOrder(
    List<GrammarToken> tokens,
    List<String> correctTokenIds,
  ) {
    if (tokens.length != correctTokenIds.length) return false;
    for (var index = 0; index < tokens.length; index++) {
      if (tokens[index].id != correctTokenIds[index]) return false;
    }
    return true;
  }
}
