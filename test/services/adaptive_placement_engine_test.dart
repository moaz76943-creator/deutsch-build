import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/language/german/german_content_quality.dart';
import 'package:deutsch_bilarabi/language/german/german_language_exercise_strategy.dart';
import 'package:deutsch_bilarabi/models/assessment.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/models/diagnostic_placement.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:deutsch_bilarabi/services/adaptive_placement_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const strategy = GermanLanguageExerciseStrategy();
  const quality = GermanContentQuality();
  final state = LearnerState(updatedAt: DateTime.utc(2026, 10, 2));
  final corpus = List<ContentItem>.generate(
    20,
    (index) => ContentItem(
      id: 'item_$index',
      german: index.isEven ? 'Haus$index' : 'lernen$index',
      arabic: 'معنى $index',
      sentence: 'Das ist Beispiel Nummer $index.',
      sentenceAr: 'هذا مثال رقم $index.',
      topic: 'diagnostic',
      skill: 'recall',
      article: index.isEven ? 'das' : '',
      accepted: <String>['Haus$index'],
    ),
  );

  test('first diagnostic question is deterministic and bounded', () {
    final first = AdaptivePlacementEngine.nextQuestion(
      items: corpus,
      state: state,
      responses: const <DiagnosticResponse>[],
      exerciseStrategy: strategy,
      isLearnable: quality.isLearnable,
      seed: 42,
    );
    final again = AdaptivePlacementEngine.nextQuestion(
      items: corpus,
      state: state,
      responses: const <DiagnosticResponse>[],
      exerciseStrategy: strategy,
      isLearnable: quality.isLearnable,
      seed: 42,
    );

    expect(first, isNotNull);
    expect(first?.question.id, again?.question.id);
    expect(first?.dimension, DiagnosticDimension.meaning);
    expect(first?.difficultyBand, inInclusiveRange(0, 3));
  });

  test('incorrect answer retests weak dimension without reusing item', () {
    final first = AdaptivePlacementEngine.nextQuestion(
      items: corpus,
      state: state,
      responses: const <DiagnosticResponse>[],
      exerciseStrategy: strategy,
      isLearnable: quality.isLearnable,
      seed: 7,
    )!;

    final second = AdaptivePlacementEngine.nextQuestion(
      items: corpus,
      state: state,
      responses: <DiagnosticResponse>[
        DiagnosticResponse(
          questionId: first.question.id,
          itemId: first.question.itemId,
          dimension: first.dimension,
          correct: false,
          hinted: false,
          skipped: false,
        ),
      ],
      exerciseStrategy: strategy,
      isLearnable: quality.isLearnable,
      seed: 7,
    );

    expect(second, isNotNull);
    expect(second?.dimension, first.dimension);
    expect(second?.question.itemId, isNot(first.question.itemId));
    expect(second!.difficultyBand, lessThanOrEqualTo(first.difficultyBand));
  });

  test('existing facet failures seed the first diagnostic weakness', () {
    final now = DateTime.utc(2026, 10, 2);
    const key = ReviewFacetKey(
      conceptId: 'noun.tisch',
      facetType: ReviewFacetType.gender,
    );
    final learner = LearnerState(
      reviewCards: <String, ReviewCard>{
        key.storageKey: ReviewCard(
          itemId: 'noun.tisch',
          facetType: ReviewFacetType.gender,
          failures: 3,
          lapses: 1,
          dueAt: now,
        ),
      },
      updatedAt: now,
    );

    final first = AdaptivePlacementEngine.nextQuestion(
      items: corpus,
      state: learner,
      responses: const <DiagnosticResponse>[],
      exerciseStrategy: strategy,
      isLearnable: quality.isLearnable,
      seed: 9,
    );

    expect(first?.dimension, DiagnosticDimension.grammar);
    expect(first?.question.accepted, isEmpty);
  });

  test('terminal punctuation does not create a false diagnostic error', () {
    const question = AssessmentQuestion(
      id: 'q',
      itemId: 'item',
      prompt: 'prompt',
      expected: 'Das Haus ist groß.',
      type: AssessmentQuestionType.translation,
      accepted: <String>[],
      skill: 'transfer',
    );
    const response = AssessmentResponse(
      questionId: 'q',
      itemId: 'item',
      answer: 'Das Haus ist groß',
      correct: true,
      hinted: false,
    );

    expect(assessmentAnswerMatches(response, question), isTrue);
  });

  test('skipped listening evidence is excluded from placement score', () {
    const responses = <DiagnosticResponse>[
      DiagnosticResponse(
        questionId: 'q1',
        itemId: 'item_1',
        dimension: DiagnosticDimension.meaning,
        correct: true,
        hinted: false,
        skipped: false,
      ),
      DiagnosticResponse(
        questionId: 'q2',
        itemId: 'item_2',
        dimension: DiagnosticDimension.listening,
        correct: false,
        hinted: false,
        skipped: true,
      ),
    ];

    final result = AdaptivePlacementEngine.score(responses);

    expect(result.scoredAnswers, 1);
    expect(result.score, 100);
    expect(result.dimensionScores.containsKey(DiagnosticDimension.listening), isFalse);
  });

  test('adaptive placement does not pretend to grade open production', () {
    final responses = <DiagnosticResponse>[];
    for (var step = 0; step < AdaptivePlacementEngine.defaultMaxQuestions; step++) {
      final question = AdaptivePlacementEngine.nextQuestion(
        items: corpus,
        state: state,
        responses: responses,
        exerciseStrategy: strategy,
        isLearnable: quality.isLearnable,
        seed: 13,
      );
      if (question == null) break;
      expect(question.dimension, isNot(DiagnosticDimension.production));
      responses.add(
        DiagnosticResponse(
          questionId: question.question.id,
          itemId: question.question.itemId,
          dimension: question.dimension,
          correct: true,
          hinted: false,
          skipped: false,
          difficultyBand: question.difficultyBand,
        ),
      );
    }
  });

  test('placement result is diagnostic band not CEFR certification', () {
    final responses = <DiagnosticResponse>[
      for (var i = 0; i < 8; i++)
        DiagnosticResponse(
          questionId: 'q$i',
          itemId: 'item_$i',
          dimension: DiagnosticDimension.values[i % 5],
          correct: i < 5,
          hinted: false,
          skipped: false,
        ),
    ];

    final result = AdaptivePlacementEngine.score(responses);

    expect(result.band, isA<DiagnosticPlacementBand>());
    expect(result.isCefrCertification, isFalse);
    expect(result.confidence, inInclusiveRange(0.0, 1.0));
  });
}
