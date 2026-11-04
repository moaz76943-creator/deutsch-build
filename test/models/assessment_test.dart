import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/models/assessment.dart';

void main() {
  group('assessmentNormalize', () {
    test('trims whitespace', () {
      expect(assessmentNormalize(' hello '), 'hello');
    });

    test('lowercases', () {
      expect(assessmentNormalize('HELLO'), 'hello');
    });

    test('removes trailing punctuation', () {
      expect(assessmentNormalize('hello.'), 'hello');
      expect(assessmentNormalize('hello!'), 'hello');
      expect(assessmentNormalize('hello?'), 'hello');
      expect(assessmentNormalize('hello.!?'), 'hello');
    });

    test('does not remove internal punctuation', () {
      expect(assessmentNormalize('hello.world'), 'hello.world');
    });

    test('normalizes internal spaces', () {
      expect(assessmentNormalize('hello   world'), 'hello world');
      expect(assessmentNormalize(' hello \t world \n '), 'hello world');
    });

    test('preserves internal apostrophes and combines whitespace and punctuation', () {
      expect(assessmentNormalize("what's up?"), "what's up");
      expect(assessmentNormalize('  HELLO \t\n WORLD.!?  '), 'hello world');
      expect(assessmentNormalize(' .!? '), '');
    });

    test('handles empty strings', () {
      expect(assessmentNormalize(''), '');
    });
  });

  group('assessmentAnswerMatches', () {
    const question = AssessmentQuestion(
      id: 'q1',
      itemId: 'i1',
      prompt: 'Translate hello',
      expected: 'hallo',
      type: AssessmentQuestionType.translation,
      accepted: ['hi', 'guten tag'],
      skill: 'vocab',
    );

    test('returns false if response is marked incorrect', () {
      const response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: 'hallo',
        correct: false,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, question), false);
    });

    test('returns true if answer is empty but correct is true (e.g. self-assessed)', () {
      const response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: '',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, question), true);
    });

    test('matches expected answer with normalization', () {
      const response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: ' HALLO! ',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, question), true);
    });

    test('matches accepted answers with normalization', () {
      const response1 = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: 'Guten Tag.',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response1, question), true);

      const response2 = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: 'HI',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response2, question), true);
    });

    test('returns false if answer does not match expected or accepted', () {
      const response = AssessmentResponse(
        questionId: 'q1',
        itemId: 'i1',
        answer: 'tschüss',
        correct: true,
        hinted: false,
      );
      expect(assessmentAnswerMatches(response, question), false);
    });
  });
}
