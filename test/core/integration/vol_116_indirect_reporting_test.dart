import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_indirect_reporting_advanced_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave2_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4902 Advanced Indirect Reporting Tests', () {
    test('LING-025: Past tense Konjunktiv I with sein constructs sei + Partizip II', () {
      final report = GermanIndirectReportingAdvancedEngine.transformStatement(
        speaker: 'Der Minister',
        directQuote: 'gestern in Berlin',
        tense: IndirectDiscourseTense.past,
        participleOrInfinitive: 'angekommen',
        requiresSeinAuxiliary: true,
      );

      expect(report.auxiliaryForm, equals('sei'));
      expect(report.shiftedPronoun, equals('er'));
      expect(report.appliedDeicticShifts['gestern'], equals('am Vortag'));
      expect(report.fullIndirectSentence, equals('Der Minister erklärte, er am Vortag in Berlin angekommen sei.'));
    });

    test('LING-025: Future tense Konjunktiv I constructs werde + Infinitiv with deictic shift', () {
      final report = GermanIndirectReportingAdvancedEngine.transformStatement(
        speaker: 'Die Forscherin',
        directQuote: 'morgen das Projekt',
        tense: IndirectDiscourseTense.future,
        participleOrInfinitive: 'beenden',
        isFemaleSpeaker: true,
      );

      expect(report.auxiliaryForm, equals('werde'));
      expect(report.shiftedPronoun, equals('sie'));
      expect(report.appliedDeicticShifts['morgen'], equals('am folgenden Tag'));
      expect(report.fullIndirectSentence, equals('Die Forscherin erklärte, sie am folgenden Tag das Projekt beenden werde.'));
    });

    test('UI Bridge generates accurate Task 4902 diagnostics report', () {
      final bridge = Vol116Wave2UIBridge();
      final report = bridge.getTask4902Diagnostics();

      expect(report['task_id'], equals(4902));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(98));
      expect(report['deictic_shifting_supported'], isTrue);
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
