import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/core/content/german_prefix_transitivity_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave49_ui_bridge.dart';

void main() {
  group('Task 4949: German Inseparable Prefix & Transitivity Engine Tests', () {
    late GermanPrefixTransitivityEngine engine;
    late Vol116Wave49UiBridge uiBridge;

    setUp(() {
      engine = GermanPrefixTransitivityEngine();
      uiBridge = Vol116Wave49UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich prefix transitivity entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
    });

    test('Prefix "be-" entries consistently enforce direct accusative without prepositions', () {
      final beEntries = engine.filterByPrefix(InseparablePrefix.be);
      expect(beEntries, isNotEmpty);
      for (final item in beEntries) {
        expect(item.governingCase, contains('Akkusativ'));
        expect(item.diagnosticTrapWarning, contains('Präposition'));
      }
    });

    test('Prefix "zer-" entries strictly express destructive physical dispersion', () {
      final zerEntries = engine.filterByPrefix(InseparablePrefix.zer);
      expect(zerEntries, isNotEmpty);
      for (final item in zerEntries) {
        expect(item.semanticFunction, equals(PrefixSemanticFunction.destructiveDispersion));
      }
    });

    test('Validator catches redundant preposition error after "beantworten"', () {
      final report = engine.validateVerbTransitivity(
        prefix: InseparablePrefix.be,
        prefixVerb: 'beantworten',
        containsRedundantPreposition: true,
        isCaseAccusativeForBe: true,
      );

      expect(report.isValid, isFalse);
      expect(report.avoidsRedundantPreposition, isFalse);
      expect(report.issues, anyElement(contains('Redundante Präposition')));
    });

    test('Validator approves compliant prefix transitivized construction', () {
      final report = engine.validateVerbTransitivity(
        prefix: InseparablePrefix.be,
        prefixVerb: 'beantworten',
        containsRedundantPreposition: false,
        isCaseAccusativeForBe: true,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalPrefixRules'], greaterThanOrEqualTo(16));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setPrefixFilter(InseparablePrefix.ver);
      expect(
        uiBridge.currentFilteredList.every((e) => e.prefix == InseparablePrefix.ver),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
