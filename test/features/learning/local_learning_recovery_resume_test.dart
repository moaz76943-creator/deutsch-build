import 'package:deutsch_bilarabi/core/content_contract.dart';
import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/learning/domain/local_learning_recovery.dart';
import 'package:deutsch_bilarabi/features/learning/domain/local_learning_recovery_resume.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resumePlanner = LocalLearningRecoveryResumePlanner();

  test('resume keeps only the unfinished saved items in their original order', () {
    final now = DateTime.utc(2026, 10, 4, 20);
    final a = _item('a', now);
    final b = _item('b', now);
    final c = _item('c', now);
    final plan = LocalLearningRecoveryPlan(
      pairKey: 'ar->de',
      generatedAtUtc: now,
      estimatedMinutes: 5,
      items: <LocalLearningRecoveryItem>[a, b, c],
    );
    final cursor = LocalLearningRecoveryResumeCursor(
      pairKey: 'ar->de',
      createdAtUtc: now.subtract(const Duration(hours: 1)),
      remainingReviewKeys: <String>[c.reviewKey, a.reviewKey, 'missing'],
    );

    final session = resumePlanner.restore(
      plan: plan,
      cursor: cursor,
      now: now,
    );

    expect(session.resumed, isTrue);
    expect(
      session.plan.items.map((item) => item.reviewKey).toList(),
      <String>[c.reviewKey, a.reviewKey],
    );
  });

  test('resume never crosses a directed pair boundary', () {
    final now = DateTime.utc(2026, 10, 4, 20);
    final item = _item('pair-safe', now);
    final plan = LocalLearningRecoveryPlan(
      pairKey: 'ar->de',
      generatedAtUtc: now,
      estimatedMinutes: 5,
      items: <LocalLearningRecoveryItem>[item],
    );

    final session = resumePlanner.restore(
      plan: plan,
      cursor: LocalLearningRecoveryResumeCursor(
        pairKey: 'de->ar',
        createdAtUtc: now,
        remainingReviewKeys: <String>[item.reviewKey],
      ),
      now: now,
    );

    expect(session.resumed, isFalse);
    expect(session.plan.pairKey, 'ar->de');
  });

  test('resume cursor persists orchestration identity only, never SRS progress', () {
    final cursor = LocalLearningRecoveryResumeCursor(
      pairKey: 'ar->de',
      createdAtUtc: DateTime.utc(2026, 10, 4),
      remainingReviewKeys: const <String>['card-a|meaningRecall|'],
    );

    expect(
      cursor.toJson().keys.toSet(),
      <String>{'pairKey', 'createdAtUtc', 'remainingReviewKeys'},
    );
    expect(cursor.toJson().containsKey('dueAt'), isFalse);
    expect(cursor.toJson().containsKey('mastery'), isFalse);
    expect(cursor.toJson().containsKey('score'), isFalse);
    expect(cursor.toJson().containsKey('xp'), isFalse);
    expect(cursor.toJson().containsKey('streak'), isFalse);
  });
}

LocalLearningRecoveryItem _item(String id, DateTime dueAt) {
  return LocalLearningRecoveryItem(
    item: _Content(id),
    reason: LocalLearningRecoveryReason.due,
    facetType: ReviewFacetType.meaningRecall,
    variantKey: null,
    dueAt: dueAt,
    incorrectCount: 0,
    successRate: 0.5,
  );
}

final class _Content implements LearningContent {
  const _Content(this.id);

  @override
  final String id;

  @override
  String get sourceText => id;

  @override
  String get translationText => 'translation-$id';

  @override
  String get exampleText => 'example-$id';

  @override
  String get exampleTranslationText => 'example-translation-$id';

  @override
  String get topic => 'recovery';

  @override
  String get skill => 'vocabulary';

  @override
  String get grammaticalMarker => '';

  @override
  String get pluralForm => '';

  @override
  List<String> get acceptedForms => const <String>[];
}
