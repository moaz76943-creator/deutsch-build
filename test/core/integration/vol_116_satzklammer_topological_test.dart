import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_satzklammer_topological_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave35_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4935 Satzklammer Topological Engine Tests', () {
    test('LING-058: Two pronouns enforce Accusative before Dative (es ihm)', () {
      final res = GermanSatzklammerTopologicalEngine.orderMittelfeldObjects(
        subject: 'Ich',
        finiteVerb: 'gebe',
        dativeObject: 'ihm',
        dativeType: ObjectRealizationType.pronounObject,
        accusativeObject: 'es',
        accusativeType: ObjectRealizationType.pronounObject,
      );

      // Must strictly be "es ihm", never "*ihm es"
      expect(res.orderedMittelfeld, equals('es ihm'));
      expect(res.fullSentence, equals('Ich gebe es ihm.'));
      expect(res.arabicRuleSummary, contains('es ihm'));
    });

    test('LING-058: Accusative pronoun precedes Dative noun', () {
      final res = GermanSatzklammerTopologicalEngine.orderMittelfeldObjects(
        subject: 'Ich',
        finiteVerb: 'gebe',
        dativeObject: 'dem Mann',
        dativeType: ObjectRealizationType.nounObject,
        accusativeObject: 'es',
        accusativeType: ObjectRealizationType.pronounObject,
      );

      expect(res.orderedMittelfeld, equals('es dem Mann'));
      expect(res.fullSentence, equals('Ich gebe es dem Mann.'));
    });

    test('LING-058: Two nouns place Dative before Accusative', () {
      final res = GermanSatzklammerTopologicalEngine.orderMittelfeldObjects(
        subject: 'Ich',
        finiteVerb: 'schenke',
        dativeObject: 'meinem Freund',
        dativeType: ObjectRealizationType.nounObject,
        accusativeObject: 'ein Buch',
        accusativeType: ObjectRealizationType.nounObject,
      );

      expect(res.orderedMittelfeld, equals('meinem Freund ein Buch'));
      expect(res.fullSentence, equals('Ich schenke meinem Freund ein Buch.'));
    });

    test('UI Bridge generates accurate Task 4935 diagnostics report', () {
      final bridge = Vol116Wave35UIBridge();
      final report = bridge.getTask4935Diagnostics();

      expect(report['task_id'], equals(4935));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(65));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
