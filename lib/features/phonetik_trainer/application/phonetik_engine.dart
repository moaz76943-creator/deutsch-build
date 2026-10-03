import '../data/phonetik_catalog.dart';
import '../domain/phonetik_models.dart';

final class PhonetikTrainerEngine {
  PhonetikTrainerEngine(Iterable<PhonetikFocus> focuses)
      : focuses = List<PhonetikFocus>.unmodifiable(focuses) {
    _validateCatalog(this.focuses);
  }

  factory PhonetikTrainerEngine.standard() =>
      PhonetikTrainerEngine(PhonetikCatalog.focuses);

  final List<PhonetikFocus> focuses;

  PhonetikFocus? focusById(String id) {
    final normalized = id.trim().toLowerCase();
    for (final focus in focuses) {
      if (focus.id.toLowerCase() == normalized) return focus;
    }
    return null;
  }

  PhonetikAnswerResult evaluate({
    required String focusId,
    required String selectedChoice,
  }) {
    final focus = focusById(focusId);
    if (focus == null) {
      throw ArgumentError.value(focusId, 'focusId', 'Unknown phonetics focus');
    }

    final selected = selectedChoice.trim();
    if (!focus.exercise.choices.contains(selected)) {
      throw ArgumentError.value(
        selectedChoice,
        'selectedChoice',
        'Choice does not belong to this exercise',
      );
    }

    final isCorrect = selected == focus.exercise.correctChoice;
    return PhonetikAnswerResult(
      isCorrect: isCorrect,
      selectedChoice: selected,
      expectedChoice: focus.exercise.correctChoice,
      feedbackAr: isCorrect
          ? 'إجابة صحيحة. ${focus.exercise.explanationAr}'
          : 'جرّب مرة أخرى. ${focus.exercise.explanationAr}',
    );
  }

  List<PhonetikFocus> practiceOrder(Set<String> completedFocusIds) {
    final completed = completedFocusIds.map((id) => id.trim()).toSet();
    return List<PhonetikFocus>.unmodifiable(<PhonetikFocus>[
      ...focuses.where((focus) => !completed.contains(focus.id)),
      ...focuses.where((focus) => completed.contains(focus.id)),
    ]);
  }

  static void _validateCatalog(List<PhonetikFocus> focuses) {
    if (focuses.isEmpty) {
      throw ArgumentError('Phonetics catalog must not be empty');
    }

    final ids = <String>{};
    for (final focus in focuses) {
      if (focus.id.trim().isEmpty || !ids.add(focus.id)) {
        throw ArgumentError('Phonetics focus ids must be non-empty and unique');
      }
      if (focus.examples.isEmpty) {
        throw ArgumentError('Every phonetics focus needs examples: ${focus.id}');
      }
      if (focus.exercise.choices.length < 2 ||
          !focus.exercise.choices.contains(focus.exercise.correctChoice)) {
        throw ArgumentError('Invalid exercise choices for ${focus.id}');
      }
    }
  }
}
