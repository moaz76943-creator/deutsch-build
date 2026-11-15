import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_tekamolo_topology_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave36_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4936 TeKaMoLo Topology Engine Tests', () {
    test('LING-059: Default subject Vorfeld aligns full TeKaMoLo sequence in order', () {
      final res = GermanTeKaMoLoTopologyEngine.assembleSentence(
        subject: 'Er',
        finiteVerb: 'fährt',
        temporal: 'heute',
        causal: 'wegen des Regens',
        modal: 'mit dem Bus',
        local: 'zur Arbeit',
        focus: VorfeldFocusChoice.subjectDefault,
      );

      expect(res.followsStrictCanonicalOrder, isTrue);
      expect(res.generatedSentence, equals('Er fährt heute wegen des Regens mit dem Bus zur Arbeit.'));
    });

    test('LING-059: Causal focus in Vorfeld triggers inversion while retaining relative order', () {
      final res = GermanTeKaMoLoTopologyEngine.assembleSentence(
        subject: 'Er',
        finiteVerb: 'fährt',
        temporal: 'heute',
        causal: 'wegen des Regens',
        modal: 'mit dem Bus',
        local: 'zur Arbeit',
        focus: VorfeldFocusChoice.causalFocus,
      );

      // Inverted: "Wegen des Regens fährt er heute mit dem Bus zur Arbeit."
      expect(res.generatedSentence, equals('Wegen des Regens fährt er heute mit dem Bus zur Arbeit.'));
      expect(res.arabicRuleSummary, contains('TeKaMoLo'));
    });

    test('LING-059: Temporal focus in Vorfeld preserves K-M-L remaining order', () {
      final res = GermanTeKaMoLoTopologyEngine.assembleSentence(
        subject: 'Wir',
        finiteVerb: 'fliegen',
        temporal: 'im Sommer',
        causal: 'zur Erholung',
        modal: 'mit der Familie',
        local: 'nach Spanien',
        focus: VorfeldFocusChoice.temporalFocus,
      );

      expect(res.generatedSentence, equals('Im Sommer fliegen wir zur Erholung mit der Familie nach Spanien.'));
    });

    test('UI Bridge generates accurate Task 4936 diagnostics report', () {
      final bridge = Vol116Wave36UIBridge();
      final report = bridge.getTask4936Diagnostics();

      expect(report['task_id'], equals(4936));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(64));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
