import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_prepositional_correlates_es_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave67_ui_bridge.dart';

void main() {
  group('Task 4967: German Prepositional Correlates & Expletive es Tests', () {
    late GermanPrepositionalCorrelatesEsEngine engine;
    late Vol116Wave67UiBridge bridge;

    setUp(() {
      engine = GermanPrepositionalCorrelatesEsEngine();
      bridge = Vol116Wave67UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('CORR-4967-'));
        expect(item.governingVerbOrPredicate.isNotEmpty, isTrue);
        expect(item.correlateToken.isNotEmpty, isTrue);
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.ungrammaticalCounterExample.isNotEmpty, isTrue);
        expect(item.syntacticExplanationGerman.isNotEmpty, isTrue);
        expect(item.syntacticExplanationArabic.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all correlate categories', () {
      for (final cat in CorrelateCategory.values) {
        final matches = engine.getByCategory(cat);
        expect(matches.isNotEmpty, isTrue, reason: 'Category ${cat.name} must have at least one exemplar');
      }
    });

    test('Engine covers all embedded clause types (dass, zu, ob, W-frage)', () {
      for (final type in EmbeddedClauseType.values) {
        final matches = engine.getByEmbeddedType(type);
        expect(matches.isNotEmpty, isTrue, reason: 'Embedded type ${type.name} must have at least one exemplar');
      }
    });

    test('Validation enforces obligatory da(r)-correlate and rejects omission', () {
      final invalidRes = engine.validateCorrelateUsage(
        category: CorrelateCategory.obligatoryPrepositionalDa,
        hasDaCorrelate: false,
        hasEsCorrelate: false,
        isVorfeldOccupiedByOtherElement: false,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Korrelatfehler'));

      final validRes = engine.validateCorrelateUsage(
        category: CorrelateCategory.obligatoryPrepositionalDa,
        hasDaCorrelate: true,
        hasEsCorrelate: false,
        isVorfeldOccupiedByOtherElement: false,
      );
      expect(validRes.isValid, isTrue);
    });

    test('Validation rejects Vorfeld-es when Vorfeld is occupied by another constituent', () {
      final invalidRes = engine.validateCorrelateUsage(
        category: CorrelateCategory.vorfeldExpletiveEsDisappearing,
        hasDaCorrelate: false,
        hasEsCorrelate: true, // Illegal retained "es" after inversion!
        isVorfeldOccupiedByOtherElement: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Topologie-Fehler'));
    });

    test('Validation rejects redundant correlates on prohibited control verbs', () {
      final invalidRes = engine.validateCorrelateUsage(
        category: CorrelateCategory.prohibitedCorrelateZero,
        hasDaCorrelate: false,
        hasEsCorrelate: true, // Illegal!
        isVorfeldOccupiedByOtherElement: false,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Redundanzfehler'));
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByCategory(CorrelateCategory.obligatoryPrepositionalDa);
      expect(bridge.state.selectedCategory, equals(CorrelateCategory.obligatoryPrepositionalDa));
      expect(
        bridge.state.activeExemplars.every((c) => c.category == CorrelateCategory.obligatoryPrepositionalDa),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedCategory, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and correlate distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['obligatoryCorrelatesCount'], greaterThanOrEqualTo(8));
    });
  });
}
