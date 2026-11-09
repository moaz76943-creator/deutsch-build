import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_relative_clause_parser.dart';
import 'package:deutsch_build/src/core/mesh/crdt/pn_counter_crdt_accumulator.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave2_ui_bridge.dart';

void main() {
  group('Volume 115 Wave 2 (Tasks 4884-4886) Integration Tests', () {
    test('ARCH-012: PnCounterCrdtAccumulator increments, decrements, and merges states', () {
      final nodeA = PnCounterCrdtAccumulator(localNodeId: 'node_A');
      final nodeB = PnCounterCrdtAccumulator(localNodeId: 'node_B');

      nodeA.increment(5);
      nodeA.decrement(2);
      expect(nodeA.value, equals(3));

      nodeB.increment(10);
      nodeB.decrement(1);
      expect(nodeB.value, equals(9));

      // Reconcile A into B and B into A
      final stateA = nodeA.exportState();
      final stateB = nodeB.exportState();

      nodeA.mergeRemoteState(stateB);
      nodeB.mergeRemoteState(stateA);

      // Convergence: 3 + 9 = 12
      expect(nodeA.value, equals(12));
      expect(nodeB.value, equals(12));
    });

    test('LING-011: GermanRelativeClauseParser extracts relative pronouns and checks verb placement', () {
      final sentence = 'Das ist der Mann, der Deutsch lernt.';
      final analysis = GermanRelativeClauseParser.parseRelativeClause(sentence);

      expect(analysis, isNotNull);
      expect(analysis!.relativePronoun, equals('der'));
      expect(analysis.antecedentNoun, equals('Mann'));
      expect(analysis.verbPlacedAtEnd, isTrue);

      // Invalid relative clause (no relative pronoun)
      final nonRel = GermanRelativeClauseParser.parseRelativeClause('Ich esse, weil ich Hunger habe.');
      expect(nonRel, isNull);
    });

    test('UI Bridge correctly generates Wave 2 diagnostics report', () {
      final bridge = Vol115Wave2UIBridge();
      final report = bridge.getWave2Diagnostics();

      expect(report['volume'], equals(115));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['pn_counter_crdt']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['relative_clause_parser']['status'], equals('ACTIVE'));
    });
  });
}
