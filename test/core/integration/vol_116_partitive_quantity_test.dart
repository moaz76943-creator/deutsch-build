import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_partitive_quantity_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave7_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4907 Partitive & Quantity Engine Tests', () {
    test('LING-030: Measure apposition constructs unmodified noun phrases cleanly', () {
      final res = GermanPartitiveQuantityEngine.buildMeasureApposition(
        quantityWord: 'ein Glas',
        substance: 'Wasser',
        modifierAdjective: 'kalt',
        gender: TargetEntityGender.neutral,
      );

      expect(res.type, equals(QuantityConstructionType.measureApposition));
      expect(res.generatedPhrase, equals('ein Glas kaltes Wasser'));
    });

    test('LING-030: Partitive genitive selects correct pronoun gender for plural group', () {
      // Einer der Männer (Masculine)
      final resMas = GermanPartitiveQuantityEngine.buildPartitiveGenitive(
        gender: TargetEntityGender.masculine,
        groupNounPlural: 'Männer',
      );
      expect(resMas.generatedPhrase, equals('einer der Männer'));

      // Eine der Frauen (Feminine)
      final resFem = GermanPartitiveQuantityEngine.buildPartitiveGenitive(
        gender: TargetEntityGender.feminine,
        groupNounPlural: 'Frauen',
      );
      expect(resFem.generatedPhrase, equals('eine der Frauen'));

      // Eines der Kinder (Neuter)
      final resNeu = GermanPartitiveQuantityEngine.buildPartitiveGenitive(
        gender: TargetEntityGender.neutral,
        groupNounPlural: 'Kinder',
      );
      expect(resNeu.generatedPhrase, equals('eines der Kinder'));
    });

    test('UI Bridge generates accurate Task 4907 diagnostics report', () {
      final bridge = Vol116Wave7UIBridge();
      final report = bridge.getTask4907Diagnostics();

      expect(report['task_id'], equals(4907));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(93));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
