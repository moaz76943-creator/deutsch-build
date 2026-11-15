import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_comparative_proportional_syntax_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave66_ui_bridge.dart';

void main() {
  group('Task 4966: German Comparative & Proportional Syntax Architecture Tests', () {
    late GermanComparativeProportionalSyntaxEngine engine;
    late Vol116Wave66UiBridge bridge;

    setUp(() {
      engine = GermanComparativeProportionalSyntaxEngine();
      bridge = Vol116Wave66UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('COMP-4966-'));
        expect(item.comparativeCarrierPhrase.isNotEmpty, isTrue);
        expect(item.primaryClause.isNotEmpty, isTrue);
        expect(item.comparativeSecondaryClause.isNotEmpty, isTrue);
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.technicalLawGerman.isNotEmpty, isTrue);
        expect(item.technicalLawArabic.isNotEmpty, isTrue);
        expect(item.wordOrderConstraintRule.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all comparative construction types', () {
      for (final type in ComparativeConstructionType.values) {
        final matches = engine.getByType(type);
        expect(matches.isNotEmpty, isTrue, reason: 'Type ${type.name} must have at least one exemplar');
      }
    });

    test('Engine covers all scaling directions (direct, inverse, threshold)', () {
      for (final scaling in ProportionalScalingDirection.values) {
        final matches = engine.getByScaling(scaling);
        expect(matches.isNotEmpty, isTrue, reason: 'Scaling ${scaling.name} must have at least one exemplar');
      }
    });

    test('Validation enforces je-clause verb-final and desto-clause V2-inversion', () {
      final invalidRes = engine.validateComparativeStructure(
        type: ComparativeConstructionType.proportionalJeDesto,
        isJeClauseVerbFinal: false, // Illegal V2 in je!
        isDestoClauseVerbSecondInverted: true,
        usesAlsForInequality: true,
        usesWieForEquality: true,
        usesSubjunctiveInAlsDass: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Topologie-Fehler im je-Satz'));

      final validRes = engine.validateComparativeStructure(
        type: ComparativeConstructionType.proportionalJeDesto,
        isJeClauseVerbFinal: true,
        isDestoClauseVerbSecondInverted: true,
        usesAlsForInequality: true,
        usesWieForEquality: true,
        usesSubjunctiveInAlsDass: true,
      );
      expect(validRes.isValid, isTrue);
      expect(validRes.syntacticNotes.isNotEmpty, isTrue);
    });

    test('Validation enforces "als" for inequality and rejects "wie"', () {
      final invalidRes = engine.validateComparativeStructure(
        type: ComparativeConstructionType.inequativeComparativeUngleichheit,
        isJeClauseVerbFinal: true,
        isDestoClauseVerbSecondInverted: true,
        usesAlsForInequality: false, // Used "wie" instead of "als"!
        usesWieForEquality: true,
        usesSubjunctiveInAlsDass: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('ausschließlich die Konjunktion "als" zulässig'));
    });

    test('Validation enforces Konjunktiv II in "zu... als dass"', () {
      final invalidRes = engine.validateComparativeStructure(
        type: ComparativeConstructionType.counterfactualDiscrepancyZuAlsDass,
        isJeClauseVerbFinal: true,
        isDestoClauseVerbSecondInverted: true,
        usesAlsForInequality: true,
        usesWieForEquality: true,
        usesSubjunctiveInAlsDass: false, // Used indicative!
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('erfordert zwingend den Konjunktiv II'));
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByType(ComparativeConstructionType.proportionalJeDesto);
      expect(bridge.state.selectedType, equals(ComparativeConstructionType.proportionalJeDesto));
      expect(
        bridge.state.activeExemplars.every((c) => c.constructionType == ComparativeConstructionType.proportionalJeDesto),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedType, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and comparative distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['constructionTypeDistribution'], isA<Map>());
    });
  });
}
