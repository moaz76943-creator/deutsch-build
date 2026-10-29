import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/models/assessment.dart';

void main() {
  group('assessmentAnswerMatches', () {
    final defaultQuestion = AssessmentQuestion(
      id: 'q1',
      itemId: 'i1',
      prompt: 'What is the answer?',
      expected: 'correct answer',
      type: AssessmentQuestionType.translation,
      accepted: ['alternative answer', 'another one'],
      skill: 'translation',
    );

    test('returns false if response is marked incorrect', () {
      final response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: 'correct answer',
        correct: false,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, defaultQuestion), isFalse);
    });

    test('returns true if answer is empty after normalization', () {
      final response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: '   ',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, defaultQuestion), isTrue);
    });

    test('returns true for exact match of expected answer', () {
      final response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: 'correct answer',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, defaultQuestion), isTrue);
    });

    test('matches correctly with different casing', () {
      final response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: 'CoRrEcT AnSwEr',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, defaultQuestion), isTrue);
    });

    test('matches correctly after removing trailing punctuation', () {
      final response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: 'correct answer!?.',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, defaultQuestion), isTrue);
    });

    test('matches correctly when multiple whitespaces are present', () {
      final response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: 'correct     answer',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, defaultQuestion), isTrue);
    });

    test('returns true if it matches one of the accepted answers', () {
      final response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: ' alternative  Answer! ',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, defaultQuestion), isTrue);
    });

    test('returns false if it does not match expected or any accepted answers', () {
      final response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: 'wrong answer',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, defaultQuestion), isFalse);
    });
  });
}
