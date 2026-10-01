import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/grammar.dart';

void main() {
  group('Grammar Models', () {
    test('GrammarTopic supports value equality', () {
      const topic1 = GrammarTopic(
        id: 't1',
        level: 'A1',
        titleDe: 'Test',
        titleAr: 'اختبار',
        summaryAr: 'ملخص',
      );

      const topic2 = GrammarTopic(
        id: 't1',
        level: 'A1',
        titleDe: 'Test',
        titleAr: 'اختبار',
        summaryAr: 'ملخص',
      );

      expect(topic1, equals(topic2));
      expect(topic1.hashCode, equals(topic2.hashCode));
    });

    test('GrammarTopic copyWith works', () {
      const topic = GrammarTopic(
        id: 't1',
        level: 'A1',
        titleDe: 'Test',
        titleAr: 'اختبار',
        summaryAr: 'ملخص',
      );

      final modified = topic.copyWith(titleDe: 'Modified');

      expect(modified.id, equals('t1'));
      expect(modified.titleDe, equals('Modified'));
      expect(modified, isNot(equals(topic)));
    });

    test('GrammarRule supports value equality with tables', () {
      const rule1 = GrammarRule(
        id: 'r1',
        title: 'Rule',
        explanationAr: 'شرح',
        table: [
          ['A', 'B'],
          ['1', '2']
        ],
      );

      const rule2 = GrammarRule(
        id: 'r1',
        title: 'Rule',
        explanationAr: 'شرح',
        table: [
          ['A', 'B'],
          ['1', '2']
        ],
      );

      expect(rule1, equals(rule2));
      expect(rule1.hashCode, equals(rule2.hashCode));
    });

    test('GrammarExample supports value equality', () {
      const ex1 = GrammarExample(german: 'Hallo', arabic: 'مرحبا');
      const ex2 = GrammarExample(german: 'Hallo', arabic: 'مرحبا');

      expect(ex1, equals(ex2));
      expect(ex1.hashCode, equals(ex2.hashCode));
    });

    test('MiniCheckQuestion supports value equality', () {
      const q1 = MiniCheckQuestion(
        id: 'q1',
        questionText: 'Q',
        options: ['A', 'B'],
        correctAnswerIndex: 0,
        explanationAr: 'Exp',
      );

      const q2 = MiniCheckQuestion(
        id: 'q1',
        questionText: 'Q',
        options: ['A', 'B'],
        correctAnswerIndex: 0,
        explanationAr: 'Exp',
      );

      expect(q1, equals(q2));
      expect(q1.hashCode, equals(q2.hashCode));
    });
  });
}
