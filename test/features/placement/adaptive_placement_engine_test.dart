import 'package:deutsch_bilarabi/features/placement/domain/adaptive_placement_engine.dart';
import 'package:deutsch_bilarabi/features/placement/domain/placement_models.dart';
import 'package:flutter_test/flutter_test.dart';

PlacementQuestion _question(PlacementLevel level, int index) {
  return PlacementQuestion(
    id: 'q-${level.label}-$index',
    promptArabic: 'سؤال تشخيصي',
    level: level,
    pattern: PlacementQuestionPattern.multipleChoice,
    options: const <PlacementOption>[
      PlacementOption(id: 'right', text: 'صحيح'),
      PlacementOption(id: 'wrong', text: 'خطأ'),
    ],
    correctOptionId: 'right',
    skillTag: index.isEven ? 'grammar' : 'vocabulary',
    reviewItemId: 'item-$index',
  );
}

AssessmentSession _run(
  AdaptivePlacementEngine engine,
  List<bool> pattern,
) {
  var session = engine.start(
    sessionId: 'test',
    now: DateTime.utc(2026, 10, 3),
    maxQuestions: 9,
  );
  for (var index = 0; index < pattern.length && !session.completed; index++) {
    final question = _question(session.currentLevel, index);
    session = engine.recordAnswer(
      session: session,
      question: question,
      selectedOptionId: pattern[index] ? 'right' : 'wrong',
    );
  }
  return session;
}

void main() {
  const engine = AdaptivePlacementEngine();

  test('correct answer raises next difficulty and wrong answer lowers it', () {
    final initial = engine.start(
      sessionId: 'transition',
      now: DateTime.utc(2026, 10, 3),
    );

    final afterCorrect = engine.recordAnswer(
      session: initial,
      question: _question(PlacementLevel.a2, 0),
      selectedOptionId: 'right',
    );
    expect(afterCorrect.currentLevel, PlacementLevel.b1);

    final afterWrong = engine.recordAnswer(
      session: afterCorrect,
      question: _question(PlacementLevel.b1, 1),
      selectedOptionId: 'wrong',
    );
    expect(afterWrong.currentLevel, PlacementLevel.a2);
  });

  test('consistently incorrect answers place learner at A1', () {
    final session = _run(engine, List<bool>.filled(9, false));
    final result = engine.resultFor(session);

    expect(session.completed, isTrue);
    expect(session.answers.length, 5);
    expect(result.level, PlacementLevel.a1);
    expect(result.proficiencyScore, lessThan(38));
    expect(result.reviewItemIds, isNotEmpty);
  });

  test('mixed adaptive evidence places learner at A2', () {
    final session = _run(
      engine,
      <bool>[true, false, true, false, true, false, true, false, true],
    );
    final result = engine.resultFor(session);

    expect(session.answers.length, 9);
    expect(result.level, PlacementLevel.a2);
    expect(result.proficiencyScore, inInclusiveRange(38, 78));
  });

  test('consistently correct answers place learner at B1', () {
    final session = _run(engine, List<bool>.filled(9, true));
    final result = engine.resultFor(session);

    expect(session.completed, isTrue);
    expect(session.answers.length, 5);
    expect(result.level, PlacementLevel.b1);
    expect(result.proficiencyScore, greaterThanOrEqualTo(78));
  });

  test('recommendations reflect missed skill evidence', () {
    final session = _run(
      engine,
      <bool>[false, true, false, true, false, true, false, true, false],
    );
    final result = engine.resultFor(session);

    expect(result.recommendations, isNotEmpty);
    expect(
      result.recommendations.any((value) => value.contains('القواعد')),
      isTrue,
    );
  });
}
