import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_concessive_adversative_connectors_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave65_ui_bridge.dart';

void main() {
  group('Task 4965: German Complex Concessive & Adversative Connectors Tests', () {
    late GermanConcessiveAdversativeConnectorsEngine engine;
    late Vol116Wave65UiBridge bridge;

    setUp(() {
      engine = GermanConcessiveAdversativeConnectorsEngine();
      bridge = Vol116Wave65UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('CONN-4965-'));
        expect(item.connectorPhrase.isNotEmpty, isTrue);
        expect(item.basePrimaryClause.isNotEmpty, isTrue);
        expect(item.secondaryLinkedClause.isNotEmpty, isTrue);
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.pragmaticDiscourseFunctionGerman.isNotEmpty, isTrue);
        expect(item.pragmaticDiscourseFunctionArabic.isNotEmpty, isTrue);
        expect(item.topologicalOrderRule.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all complex connector topology types', () {
      for (final top in ConnectorTopologyType.values) {
        final matches = engine.getByTopology(top);
        expect(matches.isNotEmpty, isTrue, reason: 'Topology ${top.name} must have at least one exemplar');
      }
    });

    test('Engine covers all clause position syntax categories', () {
      for (final syn in ClausePositionSyntax.values) {
        final matches = engine.getBySyntax(syn);
        expect(matches.isNotEmpty, isTrue, reason: 'Syntax ${syn.name} must have at least one exemplar');
      }
    });

    test('Validation enforces negative polarity in primary clause for "geschweige denn"', () {
      final invalidRes = engine.validateConnectorSyntax(
        type: ConnectorTopologyType.negativeScalarAdditive,
        hasNegativePolarityInPrimary: false, // Illegal affirmative!
        isVerbFinalInSubordinate: true,
        isV2InvertedInMain: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Polaritätsfehler'));

      final validRes = engine.validateConnectorSyntax(
        type: ConnectorTopologyType.negativeScalarAdditive,
        hasNegativePolarityInPrimary: true,
        isVerbFinalInSubordinate: true,
        isV2InvertedInMain: true,
      );
      expect(validRes.isValid, isTrue);
      expect(validRes.topologicalNotes.isNotEmpty, isTrue);
    });

    test('Validation enforces verb-final order for subordinating connectors', () {
      final invalidRes = engine.validateConnectorSyntax(
        type: ConnectorTopologyType.restrictiveConditional,
        hasNegativePolarityInPrimary: true,
        isVerbFinalInSubordinate: false, // Illegal V2 in subordinate!
        isV2InvertedInMain: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Topologie-Fehler'));
    });

    test('Validation enforces V2 inversion for Vorfeld adverbials (ungeachtet dessen)', () {
      final invalidRes = engine.validateConnectorSyntax(
        type: ConnectorTopologyType.prepositionalAdverbialCohesive,
        hasNegativePolarityInPrimary: true,
        isVerbFinalInSubordinate: true,
        isV2InvertedInMain: false, // Illegal no inversion!
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Inversionsfehler'));
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByTopology(ConnectorTopologyType.restrictiveConditional);
      expect(bridge.state.selectedTopology, equals(ConnectorTopologyType.restrictiveConditional));
      expect(
        bridge.state.activeExemplars.every((c) => c.topologyType == ConnectorTopologyType.restrictiveConditional),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedTopology, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and connector distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['negativePolarityCount'], greaterThanOrEqualTo(3));
    });
  });
}
