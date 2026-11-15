import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_passive_paraphrases_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave63_ui_bridge.dart';

void main() {
  group('Task 4963: German Passive Paraphrases Architecture Tests', () {
    late GermanPassiveParaphrasesEngine engine;
    late Vol116Wave63UiBridge bridge;

    setUp(() {
      engine = GermanPassiveParaphrasesEngine();
      bridge = Vol116Wave63UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('PASS-4963-'));
        expect(item.paraphraseExpression.isNotEmpty, isTrue);
        expect(item.canonicalPassiveEquivalent.isNotEmpty, isTrue);
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.subjectAgentSuppressionExplanationGerman.isNotEmpty, isTrue);
        expect(item.subjectAgentSuppressionExplanationArabic.isNotEmpty, isTrue);
        expect(item.modalShiftNuance.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all passive paraphrase categories', () {
      for (final type in PassiveParaphraseType.values) {
        final matches = engine.getByType(type);
        expect(matches.isNotEmpty, isTrue, reason: 'Type ${type.name} must have at least one exemplar');
      }
    });

    test('Engine covers all modal nuances (necessity, possibility, etc.)', () {
      for (final nuance in ParaphraseModalNuance.values) {
        final matches = engine.getByModalNuance(nuance);
        expect(matches.isNotEmpty, isTrue, reason: 'Nuance ${nuance.name} must have at least one exemplar');
      }
    });

    test('Validation rejects sich lassen formed from intransitive verbs', () {
      final invalidRes = engine.validatePassiveParaphrase(
        type: PassiveParaphraseType.sichLassenPlusInfinitive,
        isVerbTransitive: false, // Illegal!
        containsZuParticle: false,
        assertedNuance: ParaphraseModalNuance.purePossibility,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Valenzfehler'));
    });

    test('Validation rejects sein + zu without "zu" particle', () {
      final invalidRes = engine.validatePassiveParaphrase(
        type: PassiveParaphraseType.seinPlusZuPlusInfinitive,
        isVerbTransitive: true,
        containsZuParticle: false, // Missing "zu"!
        assertedNuance: ParaphraseModalNuance.categoricalNecessity,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Morphosyntax-Fehler'));
    });

    test('Validation approves compliant passive paraphrase structures', () {
      final validRes = engine.validatePassiveParaphrase(
        type: PassiveParaphraseType.sichLassenPlusInfinitive,
        isVerbTransitive: true,
        containsZuParticle: false,
        assertedNuance: ParaphraseModalNuance.purePossibility,
      );
      expect(validRes.isValid, isTrue);
      expect(validRes.stylisticNotes.isNotEmpty, isTrue);
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByType(PassiveParaphraseType.sichLassenPlusInfinitive);
      expect(bridge.state.selectedType, equals(PassiveParaphraseType.sichLassenPlusInfinitive));
      expect(
        bridge.state.activeExemplars.every((p) => p.paraphraseType == PassiveParaphraseType.sichLassenPlusInfinitive),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedType, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and paraphrase distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['typeDistribution'], isA<Map>());
    });
  });
}
