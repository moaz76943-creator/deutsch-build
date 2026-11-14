import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/core/content/german_inversion_expletive_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave42_ui_bridge.dart';

void main() {
  group('Task 4942: German Inversion & Expletive "es" Engine Tests', () {
    late GermanInversionExpletiveEngine engine;
    late Vol116Wave42UiBridge uiBridge;

    setUp(() {
      engine = GermanInversionExpletiveEngine();
      uiBridge = Vol116Wave42UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich C1-C2 inversion entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(12));
    });

    test('Every entry contains valid base and inverted sentences with bilingual commentary', () {
      for (final item in engine.catalog) {
        expect(item.baseCanonicalSentence, isNotEmpty);
        expect(item.invertedSentence, isNotEmpty);
        expect(item.frontedElement, isNotEmpty);
        expect(item.arabicTranslation, isNotEmpty);
        expect(item.grammaticalAnalysisArabic, isNotEmpty);
        expect(item.grammaticalAnalysisGerman, isNotEmpty);
        expect(item.wackernagelPositionRule, isNotEmpty);
      }
    });

    test('Vorfeld-es constructions correctly require obligatory drop upon fronting', () {
      final vorfeldEsItems = engine.filterByPattern(InversionPattern.vorfeldExpletiveEs);
      expect(vorfeldEsItems, isNotEmpty);
      for (final item in vorfeldEsItems) {
        expect(item.esBehavior, equals(EsDropBehavior.dropsObligatorily));
      }
    });

    test('Obligatory valence "es" verbs maintain persistence in Mittelfeld', () {
      final valenceEsItems = engine.filterByPattern(InversionPattern.obligatoryValenceEs);
      expect(valenceEsItems, isNotEmpty);
      for (final item in valenceEsItems) {
        expect(item.esBehavior, equals(EsDropBehavior.persistsInMittelfeld));
      }
    });

    test('Validation catches illegal presence of Vorfeld-es in Mittelfeld', () {
      final report = engine.validateInversion(
        frontedPhrase: 'Gestern',
        finiteVerb: 'wurde',
        postVerbElement: 'es',
        isVorfeldEsPresent: true,
        isValenceEsVerb: false,
      );

      expect(report.isValid, isFalse);
      expect(report.correctEsBehavior, isFalse);
      expect(report.issues, anyElement(contains('Ullzulässiges Vorfeld-es')));
    });

    test('Validation detects missing obligatory valence-es for verbs like "es gibt"', () {
      final report = engine.validateInversion(
        frontedPhrase: 'Hier',
        finiteVerb: 'gibt',
        postVerbElement: 'zahlreiche',
        isVorfeldEsPresent: false,
        isValenceEsVerb: true,
      );

      expect(report.isValid, isFalse);
      expect(report.correctEsBehavior, isFalse);
      expect(report.issues, anyElement(contains('Fehlendes Valenz-es')));
    });

    test('UI Bridge filters and telemetry function with high precision', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalInversionRules'], greaterThanOrEqualTo(12));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setPatternFilter(InversionPattern.participleFronting);
      expect(
        uiBridge.currentFilteredList.every((e) => e.pattern == InversionPattern.participleFronting),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
