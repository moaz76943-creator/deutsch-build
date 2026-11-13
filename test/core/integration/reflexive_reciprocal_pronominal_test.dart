import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_reflexive_reciprocal_pronominal_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave76_ui_bridge.dart';

void main() {
  group('ReflexiveReciprocalPronominalEngine & Wave76UiBridge Tests (Task #4976)', () {
    late ReflexiveReciprocalPronominalEngine engine;
    late Vol116Wave76UiBridge bridge;

    setUp(() {
      engine = ReflexiveReciprocalPronominalEngine();
      bridge = Vol116Wave76UiBridge(engine: engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('covers all 6 engineering domains with 16+ C1-C2 exemplars', () {
      expect(engine.allExemplars.length, greaterThanOrEqualTo(16));
      for (final domain in PronominalEngineeringDomain.values) {
        expect(engine.getByDomain(domain), isNotEmpty,
            reason: 'Domain $domain should have at least one exemplar');
      }
    });

    test('detects accusative reflexive trap when an accusative object is present', () {
      final result = engine.validatePronominalUsage(
        'Ich schaue mich das Schaltbild genau an.',
        refersToPersonOrTeam: false,
      );
      expect(result.isValid, isFalse);
      expect(result.correctedSuggestion, contains('mir'));
      expect(engine.telemetry.caughtReflexiveCaseErrors, equals(1));
    });

    test('detects split preposition + einander spelling error', () {
      final result = engine.validatePronominalUsage(
        'Die beiden Schichten sind optimal auf einander abgestimmt.',
        refersToPersonOrTeam: false,
      );
      expect(result.isValid, isFalse);
      expect(result.correctedSuggestion, contains('aufeinander'));
      expect(engine.telemetry.caughtReciprocalAmbiguities, equals(1));
    });

    test('detects da(r)- compound misuse when referring to persons', () {
      final result = engine.validatePronominalUsage(
        'Wir stimmen uns direkt damit ab.',
        refersToPersonOrTeam: true,
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtAnimacyPronominalErrors, equals(1));
    });

    test('accepts valid dative reflexive, fused einander, and animate prep+pronoun', () {
      final validDat = engine.validatePronominalUsage(
        'Ich schaue mir das Schaltbild genau an.',
        refersToPersonOrTeam: false,
      );
      final validFused = engine.validatePronominalUsage(
        'Die Schichten sind optimal aufeinander abgestimmt.',
        refersToPersonOrTeam: false,
      );
      final validAnimate = engine.validatePronominalUsage(
        'Wir stimmen uns direkt mit ihr ab.',
        refersToPersonOrTeam: true,
      );
      expect(validDat.isValid, isTrue);
      expect(validFused.isValid, isTrue);
      expect(validAnimate.isValid, isTrue);
    });

    test('UI bridge emits reactive state updates on domain selection and validation', () async {
      final states = <Wave76PronominalUiState>[];
      final sub = bridge.stateStream.listen(states.add);

      bridge.selectDomain(PronominalEngineeringDomain.aerospaceAndAviation);
      bridge.submitAttempt(
        'Du musst dich die Toleranzgrenzen merken.',
        refersToPersonOrTeam: false,
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states.length, equals(2));
      expect(states.first.selectedDomain,
          equals(PronominalEngineeringDomain.aerospaceAndAviation));
      expect(states.last.lastValidation?.isValid, isFalse);
      await sub.cancel();
    });
  });
}
