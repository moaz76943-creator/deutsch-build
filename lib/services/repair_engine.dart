import '../core/content_contract.dart';
import '../language/language_exercise_strategy.dart';
import '../models/mistake.dart';

class RepairEngine {
  static RepairDrill? build<T extends LearningContent>(
    MistakeRecord mistake,
    List<T> items, {
    required LanguageExerciseStrategy exerciseStrategy,
    bool Function(T item)? isLearnable,
  }) {
    T? item;
    for (final x in items) {
      if (x.id == mistake.itemId) {
        item = x;
        break;
      }
    }
    final allowed = item != null && (isLearnable?.call(item) ?? true);
    return exerciseStrategy.repairDrill(allowed ? item : null, mistake);
  }
}
