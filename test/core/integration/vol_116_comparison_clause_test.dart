import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_comparison_clause_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave8_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4908 Comparison Clause Engine Tests', () {
    test('LING-031: Equality comparison constructs genauso ... wie accurately', () {
      final res = GermanComparisonClauseEngine.buildRealComparison(
        subjectA: 'Ali',
        verb: 'ist',
        adjectiveOrAdverb: 'fleißig',
        entityB: 'Omar',
        isEquality: true,
      );

      expect(res.type, equals(ComparisonType.equalityWie));
      expect(res.fullSentence, equals('Ali ist genauso fleißig wie Omar.'));
    });

    test('LING-031: Inequality comparison constructs Komparativ + als accurately', () {
      final res = GermanComparisonClauseEngine.buildRealComparison(
        subjectA: 'Deutschland',
        verb: 'ist',
        adjectiveOrAdverb: 'größer',
        entityB: 'Österreich',
        isEquality: false,
      );

      expect(res.type, equals(ComparisonType.inequalityAls));
      expect(res.fullSentence, equals('Deutschland ist größer als Österreich.'));
    });

    test('LING-031: Hypothetical comparison with als ob sends KII verb to end', () {
      final res = GermanComparisonClauseEngine.buildHypotheticalComparison(
        matrixClause: 'Er tut so',
        subject: 'er',
        k2Verb: 'wüsste',
        remainder: 'alles',
        useAlsOb: true,
      );

      expect(res.type, equals(ComparisonType.hypotheticalAlsObEndVerb));
      expect(res.fullSentence, equals('Er tut so, als ob er alles wüsste.'));
    });

    test('LING-031: Hypothetical comparison with als inverts KII verb to Position 2', () {
      final res = GermanComparisonClauseEngine.buildHypotheticalComparison(
        matrixClause: 'Er tut so',
        subject: 'er',
        k2Verb: 'wüsste',
        remainder: 'alles',
        useAlsOb: false,
      );

      expect(res.type, equals(ComparisonType.hypotheticalAlsInversion));
      expect(res.fullSentence, equals('Er tut so, als wüsste er alles.'));
    });

    test('UI Bridge generates accurate Task 4908 diagnostics report', () {
      final bridge = Vol116Wave8UIBridge();
      final report = bridge.getTask4908Diagnostics();

      expect(report['task_id'], equals(4908));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(92));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
