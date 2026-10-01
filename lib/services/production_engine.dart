import '../core/content_contract.dart';
import '../language/language_exercise_strategy.dart';
import '../language/language_text_normalizer.dart';
import '../models/mistake.dart';
import '../models/production.dart';

class ProductionEngine {
  static ProductionTask? buildFor(
    LearningContent item, {
    required LanguageExerciseStrategy exerciseStrategy,
    MistakeRecord? mistake,
    ProductionMode? mode,
    bool Function(LearningContent item)? isLearnable,
  }) {
    if (!(isLearnable?.call(item) ?? item.exampleText.trim().isNotEmpty))
      return null;
    return exerciseStrategy.productionTask(item, mistake: mistake, mode: mode);
  }

  static bool matches(
    String answer,
    ProductionTask task, {
    required LanguageTextNormalizer textNormalizer,
  }) {
    final normalized = textNormalizer.answer(answer);
    if (normalized.isEmpty) return false;
    return task.accepted.any((x) => textNormalizer.answer(x) == normalized);
  }
}
