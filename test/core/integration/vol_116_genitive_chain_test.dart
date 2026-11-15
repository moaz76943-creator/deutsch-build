import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_genitive_chain_decoupler_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_116_wave26_ui_bridge.dart';

void main() {
  group('Volume 116 Task 4926 Genitive Chain Decoupler Tests', () {
    test('LING-049: Excessive nested genitives flagged and decoupled', () {
      final res = GermanGenitiveChainDecouplerEngine.auditAndDecouple(
        'die Entwicklung der Kosten des Baus der Brücke',
      );

      expect(res.chainDepth, greaterThanOrEqualTo(3));
      expect(res.severity, equals(GenitiveChainSeverity.excessiveThreeOrMore));
      expect(res.decoupledAlternative, isNot(equals(res.originalChain)));
      expect(res.arabicGuidance, contains('تفكيك'));
    });

    test('LING-049: Simple two-layer genitive accepted without modification', () {
      final res = GermanGenitiveChainDecouplerEngine.auditAndDecouple(
        'die Entwicklung der Kosten',
      );

      expect(res.severity, equals(GenitiveChainSeverity.acceptableTwoLayers));
      expect(res.decoupledAlternative, equals('die Entwicklung der Kosten'));
    });

    test('UI Bridge generates accurate Task 4926 diagnostics report', () {
      final bridge = Vol116Wave26UIBridge();
      final report = bridge.getTask4926Diagnostics();

      expect(report['task_id'], equals(4926));
      expect(report['volume'], equals(116));
      expect(report['tasks_remaining_to_5000'], equals(74));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
    });
  });
}
