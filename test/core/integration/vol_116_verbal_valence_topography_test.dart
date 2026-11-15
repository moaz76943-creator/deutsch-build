import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/core/content/german_verbal_valence_topography_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave54_ui_bridge.dart';

void main() {
  group('Task 4954: German Verbal Valence Topography Engine Tests', () {
    late GermanVerbalValenceTopographyEngine engine;
    late Vol116Wave54UiBridge uiBridge;

    setUp(() {
      engine = GermanVerbalValenceTopographyEngine();
      uiBridge = Vol116Wave54UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich verbal valence topography entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
    });

    test('Prepositional objects consistently use prepositional pronoun test formulas (worauf/woran)', () {
      final prepObjects = engine.filterByType(ValenceComplementType.prepositionalObject);
      expect(prepObjects, isNotEmpty);
      for (final item in prepObjects) {
        expect(item.testCategory, equals(InterrogativeTestCategory.prepositionalPronoun));
        expect(item.substitutionTestFormula, contains('Wor'));
      }
    });

    test('Directional and situational complements test with locative spatial categories', () {
      final directional = engine.filterByType(ValenceComplementType.directionalComplement);
      expect(directional, isNotEmpty);
      for (final item in directional) {
        expect(item.testCategory, equals(InterrogativeTestCategory.locativeSpatial));
      }
    });

    test('Secondary predicates remain uninflected in resultative and depictive functions', () {
      final secondary = engine.catalog.where(
        (e) =>
            e.complementType == ValenceComplementType.secondaryPredicateDepictive ||
            e.complementType == ValenceComplementType.secondaryPredicateResultative,
      );
      expect(secondary, isNotEmpty);
      for (final item in secondary) {
        expect(item.testCategory, equals(InterrogativeTestCategory.mannerDegree));
        expect(item.complementPhrase, contains('unflektiert'));
      }
    });

    test('Validator catches erroneous inflection on secondary resultative predicate', () {
      final report = engine.validateComplementStructure(
        governingVerb: 'schmieden',
        complementType: ValenceComplementType.secondaryPredicateResultative,
        isObligatorySupplied: true,
        isSecondaryPredicateUninflected: false,
      );

      expect(report.isValid, isFalse);
      expect(report.avoidsWrongAdjectiveInflection, isFalse);
      expect(report.issues, anyElement(contains('Morphologischer Fehler beim sekundären Prädikat')));
    });

    test('Validator catches missing obligatory directional complement', () {
      final report = engine.validateComplementStructure(
        governingVerb: 'stellen',
        complementType: ValenceComplementType.directionalComplement,
        isObligatorySupplied: false,
        isSecondaryPredicateUninflected: true,
      );

      expect(report.isValid, isFalse);
      expect(report.respectsObligatoryValence, isFalse);
      expect(report.issues, anyElement(contains('Valenzlücke')));
    });

    test('Validator approves fully compliant valence structure', () {
      final report = engine.validateComplementStructure(
        governingVerb: 'stellen',
        complementType: ValenceComplementType.directionalComplement,
        isObligatorySupplied: true,
        isSecondaryPredicateUninflected: true,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalValenceRules'], greaterThanOrEqualTo(16));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setTypeFilter(ValenceComplementType.secondaryPredicateResultative);
      expect(
        uiBridge.currentFilteredList.every((e) => e.complementType == ValenceComplementType.secondaryPredicateResultative),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
