import '../../core/content_contract.dart';
import '../../core/srs_facets.dart';
import '../../models/learner.dart';
import 'domain/pronunciation_models.dart';

final class PronunciationLabEngine<T extends LearningContent> {
  PronunciationLabEngine(Iterable<T> corpus)
      : _items = List<T>.unmodifiable(corpus);

  final List<T> _items;

  List<PronunciationContrast> availableContrasts(
    Iterable<PronunciationContrast> catalog,
  ) {
    final result = <PronunciationContrast>[];
    for (final contrast in catalog) {
      if (_find(contrast.leftToken) != null &&
          _find(contrast.rightToken) != null) {
        result.add(contrast);
      }
    }
    return List<PronunciationContrast>.unmodifiable(result);
  }

  PronunciationTrial<T>? buildTrial(
    PronunciationContrast contrast, {
    required int round,
  }) {
    final left = _find(contrast.leftToken);
    final right = _find(contrast.rightToken);
    if (left == null || right == null) return null;

    final chooseLeft = (_stableHash(contrast.id) + round.abs()) % 2 == 0;
    final target = chooseLeft
        ? PronunciationTarget<T>(
            item: left,
            token: contrast.leftToken,
            isLeft: true,
          )
        : PronunciationTarget<T>(
            item: right,
            token: contrast.rightToken,
            isLeft: false,
          );

    return PronunciationTrial<T>(
      contrast: contrast,
      target: target,
      leftItem: left,
      rightItem: right,
      round: round,
    );
  }

  PronunciationPerceptionResult scorePerception(
    PronunciationTrial<T> trial,
    String selectedToken,
  ) {
    final selected = _normalize(selectedToken);
    final expected = _normalize(trial.target.token);
    final correct = selected.isNotEmpty && selected == expected;
    return PronunciationPerceptionResult(
      correct: correct,
      expectedToken: trial.target.token,
      selectedToken: selectedToken.trim(),
      feedbackAr: correct
          ? 'تمييز صحيح. انتقل الآن إلى الإنتاج وكرر الصوت المستهدف.'
          : 'التمييز غير صحيح. استمع مرة أخرى ثم ركّز على الفرق المحدد في الإرشاد.',
    );
  }

  List<PronunciationConfusionStat> confusionStats(LearnerState state) {
    final attempts = <String, int>{};
    final mistakes = <String, int>{};

    for (final attempt in state.attempts) {
      if (attempt.facetType != ReviewFacetType.pronunciation) continue;
      final variant = attempt.variantKey?.trim() ?? '';
      if (!variant.startsWith('contrast:') ||
          !variant.endsWith(':perception')) {
        continue;
      }
      final parts = variant.split(':');
      if (parts.length != 3 || parts[1].isEmpty) continue;
      final id = parts[1];
      attempts[id] = (attempts[id] ?? 0) + 1;
      if (!attempt.correct) {
        mistakes[id] = (mistakes[id] ?? 0) + 1;
      }
    }

    final result = <PronunciationConfusionStat>[
      for (final entry in attempts.entries)
        PronunciationConfusionStat(
          contrastId: entry.key,
          attempts: entry.value,
          mistakes: mistakes[entry.key] ?? 0,
        ),
    ]..sort((a, b) {
        final errors = b.mistakes.compareTo(a.mistakes);
        if (errors != 0) return errors;
        return b.attempts.compareTo(a.attempts);
      });
    return List<PronunciationConfusionStat>.unmodifiable(result);
  }

  T? _find(String token) {
    final key = _normalize(token);
    if (key.isEmpty) return null;
    for (final item in _items) {
      if (_normalize(item.sourceText) == key) return item;
    }
    return null;
  }

  static String _normalize(String raw) {
    var value = raw.trim().toLowerCase();
    value = value.replaceAll(RegExp(r'\s+'), ' ');
    value = value.replaceFirst(RegExp(r'^(der|die|das)\s+'), '');
    return value.replaceAll(RegExp(r'[.!?]+$'), '').trim();
  }

  static int _stableHash(String value) {
    var hash = 17;
    for (final unit in value.codeUnits) {
      hash = ((hash * 31) + unit) & 0x7fffffff;
    }
    return hash;
  }
}
