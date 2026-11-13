import 'package:test/test.dart';
import '../../../lib/src/core/content/german_concessive_adversative_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave50_ui_bridge.dart';

void main() {
  group('Task 4950: German Concessive & Adversative Syntax Engine Tests', () {
    late GermanConcessiveAdversativeEngine engine;
    late Vol116Wave50UiBridge uiBridge;

    setUp(() {
      engine = GermanConcessiveAdversativeEngine();
      uiBridge = Vol116Wave50UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich concessive and adversative entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
    });

    test('Subordinating conjunctions strictly require verb-end positioning', () {
      final subjunctions = engine.filterByType(ConcessiveConnectorType.subordinatingConjunction);
      expect(subjunctions, isNotEmpty);
      for (final item in subjunctions) {
        expect(item.formType, equals(SyntacticFormType.subordinateClause));
      }
    });

    test('Adverbial connectors strictly enforce V2-inversion in main clauses', () {
      final adverbs = engine.filterByType(ConcessiveConnectorType.adverbialInversionConnector);
      expect(adverbs, isNotEmpty);
      for (final item in adverbs) {
        expect(item.formType, equals(SyntacticFormType.inversionMainClause));
      }
    });

    test('Validator catches colloquial use of "trotzdem" with verb-final topology', () {
      final report = engine.validateConcessiveSentence(
        connectorUsed: 'trotzdem',
        isVerbInFinalPosition: true,
        isVerbInSecondPositionWithInversion: false,
        isColloquialTrotzdemSubjunction: true,
      );

      expect(report.isValid, isFalse);
      expect(report.avoidsColloquialTrotzdem, isFalse);
      expect(report.issues, anyElement(contains('trotzdem')));
    });

    test('Validator catches missing V2-inversion after "dennoch"', () {
      final report = engine.validateConcessiveSentence(
        connectorUsed: 'dennoch',
        isVerbInFinalPosition: false,
        isVerbInSecondPositionWithInversion: false,
        isColloquialTrotzdemSubjunction: false,
      );

      expect(report.isValid, isFalse);
      expect(report.isVerbPositionCompliant, isFalse);
      expect(report.issues, anyElement(contains('Inversionsfehler')));
    });

    test('Validator approves fully compliant concessive sentence', () {
      final report = engine.validateConcessiveSentence(
        connectorUsed: 'obwohl',
        isVerbInFinalPosition: true,
        isVerbInSecondPositionWithInversion: false,
        isColloquialTrotzdemSubjunction: false,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalConcessiveRules'], greaterThanOrEqualTo(16));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setTypeFilter(ConcessiveConnectorType.scalarGeneralizingConcessive);
      expect(
        uiBridge.currentFilteredList.every((e) => e.connectorType == ConcessiveConnectorType.scalarGeneralizingConcessive),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
