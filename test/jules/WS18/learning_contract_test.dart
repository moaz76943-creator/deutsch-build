import 'dart:async';

import 'package:deutsch_bilarabi/features/flashcards/language_aware_answer_validator.dart';
import 'package:deutsch_bilarabi/features/flashcards/learning_review_coordinator.dart';
import 'package:deutsch_bilarabi/features/flashcards/verified_exercise.dart';
import 'package:deutsch_bilarabi/features/gamification/local_learning_analytics.dart';
import 'package:deutsch_bilarabi/features/wordbit/models/wordbit_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LanguageAwareAnswerValidator', () {
    test('keeps accents and umlauts semantically significant', () {
      expect(
        LanguageAwareAnswerValidator.validate(
          answer: 'haus',
          acceptedAnswers: const ['Haus'],
          languageCode: 'de',
        ),
        AnswerValidationResult.correct,
      );
      expect(
        LanguageAwareAnswerValidator.validate(
          answer: 'schon',
          acceptedAnswers: const ['schön'],
          languageCode: 'de',
        ),
        AnswerValidationResult.incorrect,
      );
      expect(
        LanguageAwareAnswerValidator.validate(
          answer: 'si',
          acceptedAnswers: const ['sí'],
          languageCode: 'es',
        ),
        AnswerValidationResult.incorrect,
      );
    });

    test('preserves Arabic diacritics instead of stripping them', () {
      expect(
        LanguageAwareAnswerValidator.validate(
          answer: 'علم',
          acceptedAnswers: const ['عَلَم'],
          languageCode: 'ar',
        ),
        AnswerValidationResult.incorrect,
      );
    });

    test('accepts canonically equivalent decomposed Latin accents', () {
      expect(
        LanguageAwareAnswerValidator.validate(
          answer: 'e\u0301cole',
          acceptedAnswers: const ['école'],
          languageCode: 'fr',
        ),
        AnswerValidationResult.correct,
      );
    });

    test('reports unavailable when verified answers are absent', () {
      expect(
        LanguageAwareAnswerValidator.validate(
          answer: 'anything',
          acceptedAnswers: const [],
          languageCode: 'en',
        ),
        AnswerValidationResult.unavailable,
      );
    });
  });

  group('LearningReviewCoordinator', () {
    test('rapid duplicate submissions write SRS only once', () async {
      final release = Completer<void>();
      var writes = 0;
      final coordinator = LearningReviewCoordinator(
        writer: ({
          required learnerContentId,
          required targetLanguageCode,
          required grade,
        }) async {
          writes++;
          await release.future;
        },
      );

      final first = coordinator.submit(
        eventId: 'event-1',
        learnerContentId: 'lex.de.1',
        sourceLanguageCode: 'ar',
        targetLanguageCode: 'de',
        grade: 3,
      );
      await Future<void>.delayed(Duration.zero);
      final second = await coordinator.submit(
        eventId: 'event-1',
        learnerContentId: 'lex.de.1',
        sourceLanguageCode: 'ar',
        targetLanguageCode: 'de',
        grade: 3,
      );

      expect(second, ReviewSubmissionStatus.duplicate);
      expect(writes, 1);
      release.complete();
      expect(await first, ReviewSubmissionStatus.accepted);
    });

    test('same event token remains isolated across directed pairs', () async {
      final writes = <String>[];
      final coordinator = LearningReviewCoordinator(
        writer: ({
          required learnerContentId,
          required targetLanguageCode,
          required grade,
        }) async {
          writes.add('$targetLanguageCode::$learnerContentId::$grade');
        },
      );

      expect(
        await coordinator.submit(
          eventId: 'shared-token',
          learnerContentId: 'lex.de.1',
          sourceLanguageCode: 'ar',
          targetLanguageCode: 'de',
          grade: 4,
        ),
        ReviewSubmissionStatus.accepted,
      );
      expect(
        await coordinator.submit(
          eventId: 'shared-token',
          learnerContentId: 'lex.fr.1',
          sourceLanguageCode: 'ar',
          targetLanguageCode: 'fr',
          grade: 4,
        ),
        ReviewSubmissionStatus.accepted,
      );
      expect(writes, hasLength(2));
      expect(writes, contains('de::lex.de.1::4'));
      expect(writes, contains('fr::lex.fr.1::4'));
    });
  });

  group('verified content mapping', () {
    test('WordBitCard exposes only attested row data', () {
      final card = WordBitCard.fromLexiconRow(
        <String, dynamic>{
          'id': 'lex.fr.1',
          'surface': 'maison',
          'display_text': 'maison',
          'language_code': 'fr',
          'part_of_speech': 'noun',
          'translation_ar': 'منزل',
          'translation_language_code': 'ar',
          'sentence': 'La maison est calme.',
          'fields': <String, dynamic>{
            'ipa': 'mɛ.zɔ̃',
            'grammar_note': 'Nom féminin',
            'article': 'la',
            'plural': 'maisons',
            'semantic_concept_id': 'concept.home',
          },
        },
        sourceLanguageCode: 'ar',
      );

      expect(card.id, 'lex.fr.1');
      expect(card.term, 'maison');
      expect(card.translation, 'منزل');
      expect(card.exampleSentence, 'La maison est calme.');
      expect(card.grammarNote, 'Nom féminin');
      expect(card.article, 'la');
      expect(card.plural, 'maisons');
      expect(card.semanticConceptId, 'concept.home');
      expect(card.bcp47Locale, 'fr');
    });

    test('verified exercise uses source answer without inventing distractors', () {
      final exercise = VerifiedExercise.fromPackRow(
        <String, dynamic>{
          'prompt': 'Artikel für Haus',
          'correct_answer': 'das',
          'distractors_json': '["der","die"]',
        },
        conceptId: 'concept.home',
        languageCode: 'de',
      );

      expect(exercise.correctAnswer, 'das');
      expect(exercise.options, containsAll(<String>['das', 'der', 'die']));
      expect(exercise.options, hasLength(3));
    });
  });

  test('progress report is derived from stored SRS rows, not constants', () {
    final now = DateTime.utc(2026, 10, 13, 12);
    final report = LocalLearningAnalytics.computeReportFromRows(
      <Map<String, dynamic>>[
        <String, dynamic>{
          'lexeme_id': 'lex.de.1',
          'target_language_code': 'de',
          'repetition_count': 4,
          'interval_days': 30,
          'next_due_at': now.millisecondsSinceEpoch ~/ 1000 - 1,
          'last_reviewed_at': DateTime.utc(2026, 10, 13, 9)
                  .millisecondsSinceEpoch ~/
              1000,
        },
        <String, dynamic>{
          'lexeme_id': 'lex.fr.1',
          'target_language_code': 'fr',
          'repetition_count': 3,
          'interval_days': 21,
          'next_due_at': now.millisecondsSinceEpoch ~/ 1000 + 86400,
          'last_reviewed_at': DateTime.utc(2026, 10, 12, 8)
                  .millisecondsSinceEpoch ~/
              1000,
        },
        <String, dynamic>{
          'lexeme_id': 'lex.de.2',
          'target_language_code': 'de',
          'repetition_count': 1,
          'interval_days': 1,
          'next_due_at': null,
          'last_reviewed_at': null,
        },
      ],
      now: now,
    );

    expect(report['mastered_cards'], 2);
    expect(report['active_languages'], 2);
    expect(report['due_cards'], 2);
    expect(report['review_days_30d'], 2);
    expect(report['observed_streak_days'], 2);
  });
}
