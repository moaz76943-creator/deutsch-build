import 'package:test/test.dart';
import '../../../lib/src/core/content/german_circumposition_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave39_ui_bridge.dart';

void main() {
  group('Task 4939: German Circumposition & Postposition Engine Tests', () {
    late GermanCircumpositionEngine engine;
    late Vol116Wave39UiBridge uiBridge;

    setUp(() {
      engine = GermanCircumpositionEngine();
      uiBridge = Vol116Wave39UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich C1-C2 constructions', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(12));
    });

    test('Circumpositions have both lead and tail components', () {
      final circumpositions = engine.filterByType(PositionalType.circumposition);
      expect(circumpositions, isNotEmpty);
      for (final item in circumpositions) {
        expect(item.leadComponent, isNotEmpty);
        expect(item.tailComponent, isNotEmpty);
        expect(item.completePhrase, contains(item.coreNoun));
      }
    });

    test('Postpositions have empty lead component and present tail component', () {
      final postpositions = engine.filterByType(PositionalType.postposition);
      expect(postpositions, isNotEmpty);
      for (final item in postpositions) {
        expect(item.leadComponent, isEmpty);
        expect(item.tailComponent, isNotEmpty);
      }
    });

    test('Validation catches invalid case for "um ... willen"', () {
      final report = engine.validatePhrase(
        leadWord: 'um',
        tailWord: 'willen',
        appliedCase: GermanCase.dative,
        expectedType: PositionalType.circumposition,
      );

      expect(report.isValid, isFalse);
      expect(report.correctCaseSelected, isFalse);
      expect(report.issues, anyElement(contains('Genitiv')));
    });

    test('Validation catches invalid case for postposed "entlang"', () {
      final report = engine.validatePhrase(
        leadWord: '',
        tailWord: 'entlang',
        appliedCase: GermanCase.dative,
        expectedType: PositionalType.postposition,
      );

      expect(report.isValid, isFalse);
      expect(report.correctCaseSelected, isFalse);
      expect(report.issues, anyElement(contains('Akkusativ')));
    });

    test('Validation confirms correct postposed "zufolge" with Dative', () {
      final report = engine.validatePhrase(
        leadWord: '',
        tailWord: 'zufolge',
        appliedCase: GermanCase.dative,
        expectedType: PositionalType.postposition,
      );

      expect(report.isValid, isTrue);
      expect(report.correctCaseSelected, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry function with high precision', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalAdpositionRules'], greaterThanOrEqualTo(12));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setTypeFilter(PositionalType.circumposition);
      expect(
        uiBridge.currentFilteredList.every((e) => e.positionalType == PositionalType.circumposition),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
