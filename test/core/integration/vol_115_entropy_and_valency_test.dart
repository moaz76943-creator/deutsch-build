import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_verb_valency_matcher.dart';
import 'package:deutsch_build/src/core/mesh/protocol/anti_entropy_reconciliation_protocol.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave1_ui_bridge.dart';

void main() {
  group('Volume 115 Wave 1 (Tasks 4881-4883) Integration Tests', () {
    test('ARCH-011: AntiEntropyReconciliationProtocol reconciles records with LWW tie-break', () {
      final node = AntiEntropyReconciliationProtocol(localNodeId: 'node_alpha');

      node.putLocal('vocab_100', 'Apfel');
      expect(node.localRecordCount, equals(1));
      expect(node.getRecord('vocab_100')?.version, equals(1));

      // Remote record with higher version must overwrite
      final remoteHigher = VersionedRecord(
        key: 'vocab_100',
        value: 'Der Apfel',
        version: 2,
        physicalTimestampUtc: 1000,
        originNodeId: 'node_beta',
      );
      final updated = node.reconcileRemoteRecord(remoteHigher);
      expect(updated, isTrue);
      expect(node.getRecord('vocab_100')?.value, equals('Der Apfel'));

      // Remote record with lower version must be rejected
      final remoteLower = VersionedRecord(
        key: 'vocab_100',
        value: 'Old',
        version: 1,
        physicalTimestampUtc: 2000,
        originNodeId: 'node_gamma',
      );
      final rejected = node.reconcileRemoteRecord(remoteLower);
      expect(rejected, isFalse);
    });

    test('LING-010: GermanVerbValencyMatcher validates required prepositions and cases', () {
      expect(GermanVerbValencyMatcher.validatePreposition('warten', 'auf'), isTrue);
      expect(GermanVerbValencyMatcher.validatePreposition('warten', 'mit'), isFalse);

      final valency = GermanVerbValencyMatcher.findValency('gehören');
      expect(valency, isNotNull);
      expect(valency!.requiredPreposition, equals('zu'));
      expect(valency.requiredCase, equals(PrepositionalCase.dative));
    });

    test('UI Bridge correctly generates Wave 1 diagnostics report', () {
      final bridge = Vol115Wave1UIBridge();
      final report = bridge.getWave1Diagnostics();

      expect(report['volume'], equals(115));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['anti_entropy_reconciliation']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['verb_valency_matcher']['status'], equals('ACTIVE'));
      expect(bridge.checkValency('interessieren', 'für'), isTrue);
    });
  });
}
