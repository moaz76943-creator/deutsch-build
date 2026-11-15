import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_adverbial_tri_transform_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave1_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4901 Adverbial Tri-Way Transform Tests', () {
    test('LING-024: Causal cluster provides exact equivalents across 3 registers', () {
      final cluster = GermanAdverbialTriTransformEngine.findCluster(AdverbialLogicCategory.causal);

      expect(cluster.subordinateClause, contains('Weil'));
      expect(cluster.conjunctiveAdverbSentence, contains('deshalb'));
      expect(cluster.prepositionalPhraseSentence, contains('Wegen'));
      expect(cluster.arabicExplanation, contains('السببية'));
    });

    test('LING-024: Concessive cluster provides exact equivalents across 3 registers', () {
      final cluster = GermanAdverbialTriTransformEngine.findCluster(AdverbialLogicCategory.concessive);

      expect(cluster.subordinateClause, contains('Obwohl'));
      expect(cluster.conjunctiveAdverbSentence, contains('trotzdem'));
      expect(cluster.prepositionalPhraseSentence, contains('Trotz'));
    });

    test('LING-024: Syntactic detector identifies registers accurately', () {
      expect(
        GermanAdverbialTriTransformEngine.detectType('Weil es regnet, bleibe ich.'),
        equals(AdverbialSyntacticType.subordinateClause),
      );
      expect(
        GermanAdverbialTriTransformEngine.detectType('Wegen des Regens bleibe ich.'),
        equals(AdverbialSyntacticType.prepositionalPhrase),
      );
    });

    test('UI Bridge generates accurate Task 4901 diagnostics report', () {
      final bridge = Vol116Wave1UIBridge();
      final report = bridge.getTask4901Diagnostics();

      expect(report['task_id'], equals(4901));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(99));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
