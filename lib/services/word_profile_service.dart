import '../core/content_contract.dart';
import 'search_index.dart';
import 'verb_index.dart';
import '../models/learner.dart';
import '../models/word_profile.dart';
import '../language/language_text_normalizer.dart';
import 'mastery.dart';

class WordProfileService {
  static WordProfile<T> build<T extends LearningContent>(
    T item,
    LearnerState state, {
    required SearchIndex<T> searchIndex,
    required VerbIndex verbIndex,
    required LanguageTextNormalizer textNormalizer,
    List<T>? corpus,
    List<Attempt>? itemAttempts,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final attempts = (itemAttempts ??
            state.meaningAttempts
                .where((x) => x.itemId == item.id)
                .toList(growable: false))
        .where((attempt) => attempt.isMeaningFacet)
        .toList(growable: false);
    final due = state.reviewCards[item.id]?.dueAt.isBefore(at) ?? false;
    final evidence = Mastery.forItemRows(
      item.id,
      attempts,
      reviewCard: state.reviewCards[item.id],
    );
    final mastery = evidence.skillScores.isEmpty
        ? 0.0
        : (evidence.overall * .70 + evidence.retention * .30)
            .clamp(0.0, 1.0)
            .toDouble();
    final forms = <String>{};
    final words = <String>{};
    final examples = <String>{};
    final key = textNormalizer.answer(item.sourceText);
    for (final v in verbIndex.rowsFor(item.sourceText)) {
      forms.add(v.form);
      forms.add(v.past);
      examples.add(v.example);
      examples.add(v.pastExample);
    }
    final topicItems = searchIndex.topicGroups[item.topic] ?? <T>[];
    for (final x in topicItems) {
      if (x.id != item.id && words.length < 8) words.add(x.sourceText);
    }
    final sameSkillItems = searchIndex.skillGroups[item.skill] ?? <T>[];
    for (final x in sameSkillItems) {
      if (x.id == item.id || examples.length >= 8) continue;
      if (textNormalizer.answer(x.exampleText).contains(key))
        examples.add(x.exampleText);
    }
    return WordProfile(
      item: item,
      relatedForms: forms.take(10).toList(growable: false),
      relatedWords: words.take(8).toList(growable: false),
      relatedExamples: examples.take(6).toList(growable: false),
      attempts: attempts.length,
      errors: attempts.where((x) => !x.correct).length,
      due: due,
      masteryScore: mastery,
    );
  }
}
