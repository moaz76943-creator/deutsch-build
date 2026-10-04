import 'canonical_curriculum_50.dart';
import 'omni_directional_matrix.dart';

void main() {
  final matrix = OmniDirectionalLearningMatrix.standard20();

  _expect(matrix.languages.length, 20, 'exact project roster has 20 identities');
  _expect(matrix.directedPairCount, 380, '20 languages create 380 ordered pairs');

  final arToDe = matrix.requirePair('ar', 'de');
  final deToAr = matrix.requirePair('de', 'ar');

  _expect(arToDe.id, 'ar->de', 'source-target pair identity');
  _expect(deToAr.id, 'de->ar', 'reverse pair identity');
  _expect(arToDe == deToAr, false, 'A→B is not B→A');
  _expect(arToDe.source.id, 'ar', 'source role is explicit');
  _expect(arToDe.target.id, 'de', 'target role is explicit');

  final plan = PairAwareCurriculumPlan.build(
    pair: arToDe,
    tasks: CanonicalCurriculum50.tasks,
  );

  _expect(plan.pair.id, 'ar->de', 'plan keeps directed pair');
  _expect(plan.tasks.length, 50, 'pair plan binds all canonical tasks');
  _expect(
    plan.tasks.first.pairTaskId,
    'ar->de::task-01',
    'pair task id is direction-specific',
  );
  _expect(
    plan.tasks.first.promptLanguageId,
    'ar',
    'lesson prompt language follows SOURCE',
  );
  _expect(
    plan.tasks.first.responseLanguageId,
    'de',
    'lesson response language follows TARGET',
  );

  final reversePlan = PairAwareCurriculumPlan.build(
    pair: deToAr,
    tasks: CanonicalCurriculum50.tasks,
  );
  _expect(
    reversePlan.tasks.first.pairTaskId,
    'de->ar::task-01',
    'reverse curriculum is separately identified',
  );

  var sameLanguageRejected = false;
  try {
    matrix.requirePair('de', 'de');
  } on ArgumentError {
    sameLanguageRejected = true;
  }
  _expect(
    sameLanguageRejected,
    true,
    'same-language learning pair is rejected',
  );

  var unknownLanguageRejected = false;
  try {
    matrix.requirePair('xx', 'de');
  } on ArgumentError {
    unknownLanguageRejected = true;
  }
  _expect(
    unknownLanguageRejected,
    true,
    'unknown language id is rejected',
  );
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}
