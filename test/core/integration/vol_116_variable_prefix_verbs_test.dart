import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_variable_prefix_verbs_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave58_ui_bridge.dart';

void main() {
  group('Task 4958: German Variable Prefix Verbs Architecture Tests', () {
    late GermanVariablePrefixVerbsEngine engine;
    late Vol116Wave58UiBridge bridge;

    setUp(() {
      engine = GermanVariablePrefixVerbsEngine();
      bridge = Vol116Wave58UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('PREF-4958-'));
        expect(item.verbLemma.isNotEmpty, isTrue);
        expect(item.accentedSyllableForm.isNotEmpty, isTrue);
        expect(item.presentTenseV2Example.isNotEmpty, isTrue);
        expect(item.perfectTenseParticipleExample.isNotEmpty, isTrue);
        expect(item.infinitiveWithZuExample.isNotEmpty, isTrue);
        expect(item.meaningGerman.isNotEmpty, isTrue);
        expect(item.meaningArabic.isNotEmpty, isTrue);
        expect(item.valencePattern.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all variable prefix morphemes (durch, über, unter, um, wider, hinter)', () {
      for (final p in PrefixMorpheme.values) {
        final matches = engine.getByPrefix(p);
        expect(matches.isNotEmpty, isTrue, reason: 'Prefix ${p.name} must have at least one exemplar');
      }
    });

    test('Engine covers both separable and inseparable statuses', () {
      for (final status in SeparabilityStatus.values) {
        final matches = engine.getBySeparability(status);
        expect(matches.isNotEmpty, isTrue, reason: 'Status ${status.name} must have exemplars');
      }
    });

    test('Validation detects illegal non-separation in V2 for separable verbs', () {
      final res = engine.validatePrefixUsage(
        verbLemma: 'durchbrechen',
        isSeparable: true,
        v2SeparatedInMainClause: false,
        participleHasGe: true,
        zuInsertedInsideVerb: true,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('Topologie-Fehler'));
    });

    test('Validation detects illegal ge- prefix in inseparable verbs', () {
      final res = engine.validatePrefixUsage(
        verbLemma: 'durchbrechen',
        isSeparable: false,
        v2SeparatedInMainClause: false,
        participleHasGe: true,
        zuInsertedInsideVerb: false,
      );
      expect(res.isValid, isFalse);
      expect(res.issues.first, contains('Morphologie-Fehler'));
    });

    test('Validation accepts compliant separable verb syntax', () {
      final res = engine.validatePrefixUsage(
        verbLemma: 'durchbrechen',
        isSeparable: true,
        v2SeparatedInMainClause: true,
        participleHasGe: true,
        zuInsertedInsideVerb: true,
      );
      expect(res.isValid, isTrue);
      expect(res.morphosyntacticNotes.isNotEmpty, isTrue);
    });

    test('Validation accepts compliant inseparable verb syntax', () {
      final res = engine.validatePrefixUsage(
        verbLemma: 'durchdringen',
        isSeparable: false,
        v2SeparatedInMainClause: false,
        participleHasGe: false,
        zuInsertedInsideVerb: false,
      );
      expect(res.isValid, isTrue);
      expect(res.morphosyntacticNotes.isNotEmpty, isTrue);
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByPrefix(PrefixMorpheme.durch);
      expect(bridge.state.selectedPrefix, equals(PrefixMorpheme.durch));
      expect(bridge.state.activeExemplars.every((v) => v.prefix == PrefixMorpheme.durch), isTrue);

      bridge.resetFilters();
      expect(bridge.state.selectedPrefix, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and prefix distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['prefixDistribution'], isA<Map>());
    });
  });
}
