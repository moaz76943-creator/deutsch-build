import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_negation_scope_polarity_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave68_ui_bridge.dart';

void main() {
  group('Task 4968: German Negation Scope, Polarity Licensing & Litotes Tests', () {
    late GermanNegationScopePolarityEngine engine;
    late Vol116Wave68UiBridge bridge;

    setUp(() {
      engine = GermanNegationScopePolarityEngine();
      bridge = Vol116Wave68UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('NEG-4968-'));
        expect(item.negationOperator.isNotEmpty, isTrue);
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.ungrammaticalPlacementExample.isNotEmpty, isTrue);
        expect(item.semanticEffectGerman.isNotEmpty, isTrue);
        expect(item.semanticEffectArabic.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all negation scope categories', () {
      for (final scope in NegationScopeType.values) {
        final matches = engine.getByScopeType(scope);
        expect(matches.isNotEmpty, isTrue, reason: 'Scope ${scope.name} must have at least one exemplar');
      }
    });

    test('Engine covers all Mittelfeld anchor positions', () {
      for (final anchor in MittelfeldNegationAnchor.values) {
        final matches = engine.getByAnchor(anchor);
        expect(matches.isNotEmpty, isTrue, reason: 'Anchor ${anchor.name} must have at least one exemplar');
      }
    });

    test('Validation rejects accidental double negation (Negative Concord)', () {
      final invalidRes = engine.validateNegationStructure(
        scopeType: NegationScopeType.indefiniteArticleNegationKein,
        isPlacedBeforeFvgOrPpOrDirectional: true,
        usesKeinForIndefiniteOrBareNoun: true,
        hasNegativeLicensorForNpi: true,
        hasAccidentalDoubleNegation: true, // Illegal Negative Concord!
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Negative-Concord-Verstoß'));
    });

    test('Validation approves intentional diplomatic Litotes', () {
      final validRes = engine.validateNegationStructure(
        scopeType: NegationScopeType.diplomaticLitotesDoubleNegation,
        isPlacedBeforeFvgOrPpOrDirectional: true,
        usesKeinForIndefiniteOrBareNoun: true,
        hasNegativeLicensorForNpi: true,
        hasAccidentalDoubleNegation: true, // Allowed for Litotes
      );
      expect(validRes.isValid, isTrue);
      expect(validRes.syntacticNotes.first, contains('Litotes'));
    });

    test('Validation rejects unlicensed NPI without negative licensor', () {
      final invalidRes = engine.validateNegationStructure(
        scopeType: NegationScopeType.negativePolarityItemLicensing,
        isPlacedBeforeFvgOrPpOrDirectional: true,
        usesKeinForIndefiniteOrBareNoun: true,
        hasNegativeLicensorForNpi: false, // Unlicensed!
        hasAccidentalDoubleNegation: false,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Lizenzierungsfehler'));
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByScopeType(NegationScopeType.negativePolarityItemLicensing);
      expect(bridge.state.selectedScopeType, equals(NegationScopeType.negativePolarityItemLicensing));
      expect(
        bridge.state.activeExemplars.every((n) => n.scopeType == NegationScopeType.negativePolarityItemLicensing),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedScopeType, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain, NPI, and Litotes counts', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['npiCount'], greaterThanOrEqualTo(3));
      expect(telemetry['litotesCount'], greaterThanOrEqualTo(3));
    });
  });
}
