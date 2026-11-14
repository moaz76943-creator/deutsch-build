import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/core/content/german_correlative_connectors_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave47_ui_bridge.dart';

void main() {
  group('Task 4947: German Correlative Connectors & Topological Asymmetry Engine Tests', () {
    late GermanCorrelativeConnectorsEngine engine;
    late Vol116Wave47UiBridge uiBridge;

    setUp(() {
      engine = GermanCorrelativeConnectorsEngine();
      uiBridge = Vol116Wave47UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich correlative connector entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
    });

    test('je ... desto constructions strictly enforce subordinate verb-final and V2 main clause', () {
      final jeDestoEntries = engine.filterByPairType(CorrelativePairType.jeDestoUmso);
      expect(jeDestoEntries, isNotEmpty);
      for (final item in jeDestoEntries) {
        expect(item.firstClauseTopology, equals(ClauseTopologyBehavior.subordinateVerbFinal));
        expect(item.secondClauseTopology, equals(ClauseTopologyBehavior.inversionForced));
      }
    });

    test('entweder ... oder constructions accurately reflect Position 0 for oder', () {
      final entwederOderEntries = engine.filterByPairType(CorrelativePairType.entwederOder);
      expect(entwederOderEntries, isNotEmpty);
      for (final item in entwederOderEntries) {
        expect(item.secondClauseTopology, equals(ClauseTopologyBehavior.positionZeroRegular));
      }
    });

    test('weder ... noch constructions demand inversion in second clause and reject double negation', () {
      final wederNochEntries = engine.filterByPairType(CorrelativePairType.wederNoch);
      expect(wederNochEntries, isNotEmpty);
      final reportWithDoubleNegation = engine.validateCorrelativeSentence(
        pairType: CorrelativePairType.wederNoch,
        isVerbInSecondPositionAfterNoch: true,
        hasPositionZeroAfterOder: true,
        isJeClauseVerbFinal: true,
        hasProhibitedDoubleNegation: true,
      );
      expect(reportWithDoubleNegation.isValid, isFalse);
      expect(reportWithDoubleNegation.isPolarityRespected, isFalse);
      expect(reportWithDoubleNegation.issues, anyElement(contains('Doppelnegation')));
    });

    test('Validator catches wrong inversion after oder', () {
      final report = engine.validateCorrelativeSentence(
        pairType: CorrelativePairType.entwederOder,
        isVerbInSecondPositionAfterNoch: true,
        hasPositionZeroAfterOder: false,
        isJeClauseVerbFinal: true,
        hasProhibitedDoubleNegation: false,
      );
      expect(report.isValid, isFalse);
      expect(report.issues, anyElement(contains('Wortstellungsfehler nach "oder"')));
    });

    test('Validator approves fully compliant correlative construction', () {
      final report = engine.validateCorrelativeSentence(
        pairType: CorrelativePairType.jeDestoUmso,
        isVerbInSecondPositionAfterNoch: true,
        hasPositionZeroAfterOder: true,
        isJeClauseVerbFinal: true,
        hasProhibitedDoubleNegation: false,
      );
      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalCorrelativeRules'], greaterThanOrEqualTo(16));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setPairFilter(CorrelativePairType.einerseitsAndererseits);
      expect(
        uiBridge.currentFilteredList.every((e) => e.pairType == CorrelativePairType.einerseitsAndererseits),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
