import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/core/srs_facets.dart';
import 'package:deutsch_bilarabi/features/pronunciation/pronunciation_lab_engine.dart';
import 'package:deutsch_bilarabi/language/german/german_pronunciation_catalog.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/models/learner.dart';

void main() {
  const corpus = <ContentItem>[
    ContentItem(
      id: 'staat',
      german: 'Staat',
      arabic: 'دولة',
      sentence: '',
      sentenceAr: '',
      topic: 'test',
      skill: 'recall',
    ),
    ContentItem(
      id: 'stadt',
      german: 'die Stadt',
      arabic: 'المدينة',
      sentence: '',
      sentenceAr: '',
      topic: 'test',
      skill: 'recall',
    ),
    ContentItem(
      id: 'fuehlen',
      german: 'fühlen',
      arabic: 'يشعر',
      sentence: '',
      sentenceAr: '',
      topic: 'test',
      skill: 'recall',
    ),
    ContentItem(
      id: 'fuellen',
      german: 'füllen',
      arabic: 'يملأ',
      sentence: '',
      sentenceAr: '',
      topic: 'test',
      skill: 'recall',
    ),
  ];

  test('filters catalog to contrasts backed by canonical content', () {
    final engine = PronunciationLabEngine<ContentItem>(corpus);
    final available = engine.availableContrasts(
      GermanPronunciationCatalog.contrasts,
    );

    expect(
      available.map((item) => item.id),
      containsAll(<String>['vowel_length_aa', 'rounded_y_length']),
    );
    expect(
      available.map((item) => item.id),
      isNot(contains('front_rounding_oe')),
    );
  });

  test('scores discrimination and preserves target concept identity', () {
    final engine = PronunciationLabEngine<ContentItem>(corpus);
    final contrast = engine
        .availableContrasts(GermanPronunciationCatalog.contrasts)
        .first;
    final trial = engine.buildTrial(contrast, round: 3)!;

    final correct = engine.scorePerception(trial, trial.target.token);
    expect(correct.correct, isTrue);
    expect(<String>['staat', 'stadt'], contains(trial.target.item.id));
  });

  test('tracks pronunciation contrast confusions independently', () {
    final now = DateTime.utc(2026, 10, 2);
    final state = LearnerState(
      attempts: <Attempt>[
        Attempt(
          id: 'a1',
          itemId: 'staat',
          skill: 'recall',
          answer: 'Stadt',
          correct: false,
          hinted: false,
          seconds: 5,
          at: now,
          facetType: ReviewFacetType.pronunciation,
          variantKey: 'contrast:vowel_length_aa:perception',
        ),
        Attempt(
          id: 'a2',
          itemId: 'staat',
          skill: 'recall',
          answer: 'Staat',
          correct: true,
          hinted: false,
          seconds: 5,
          at: now,
          facetType: ReviewFacetType.pronunciation,
          variantKey: 'contrast:vowel_length_aa:perception',
        ),
        Attempt(
          id: 'a3',
          itemId: 'staat',
          skill: 'recall',
          answer: 'Stadt',
          correct: false,
          hinted: false,
          seconds: 5,
          at: now,
          facetType: ReviewFacetType.listening,
        ),
      ],
      updatedAt: now,
    );

    final stats = PronunciationLabEngine<ContentItem>(corpus)
        .confusionStats(state);
    expect(stats, hasLength(1));
    expect(stats.single.contrastId, 'vowel_length_aa');
    expect(stats.single.attempts, 2);
    expect(stats.single.mistakes, 1);
  });
}
