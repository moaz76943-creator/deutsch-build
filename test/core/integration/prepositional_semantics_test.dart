import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_prepositional_semantics_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave79_ui_bridge.dart';

void main() {
  group('PrepositionalSemanticsEngine & Wave79UiBridge Tests (Task #4979)', () {
    late PrepositionalSemanticsEngine engine;
    late Vol116Wave79UiBridge bridge;

    setUp(() {
      engine = PrepositionalSemanticsEngine();
      bridge = Vol116Wave79UiBridge(engine: engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('covers all 6 engineering domains with 16+ C1-C2 exemplars', () {
      expect(engine.allExemplars.length, greaterThanOrEqualTo(16));
      for (final domain in PrepositionEngineeringDomain.values) {
        expect(engine.getByDomain(domain), isNotEmpty,
            reason: 'Domain $domain should have at least one exemplar');
      }
    });

    test('detects abstract Wechselpräposition case errors for basieren auf and verfügen über', () {
      final aufTrap = engine.validatePrepositionalPhrase(
        'Die Netzprognose basiert auf eine hochauflösende Zeitreihe.',
      );
      final ueberTrap = engine.validatePrepositionalPhrase(
        'Der Roboter verfügt über einem integrierten Sensor.',
      );
      expect(aufTrap.isValid, isFalse);
      expect(ueberTrap.isValid, isFalse);
      expect(engine.telemetry.caughtAbstractWechselErrors, equals(2));
    });

    test('detects missing von-fallback after aufgrund with articleless plural', () {
      final result = engine.validatePrepositionalPhrase(
        'Aufgrund Netzengpässen mussten zwei Windparks abgeregelt werden.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtGenitiveFallbackErrors, equals(1));
    });

    test('detects seit + past passive mismatch vs. vor + past passive', () {
      final result = engine.validatePrepositionalPhrase(
        'Seit zwei Stunden wurde die neue Software aufgespielt.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtSeitTenseErrors, equals(1));
    });

    test('accepts valid C1-C2 abstract prepositional governance and temporal semantics', () {
      final validBasieren = engine.validatePrepositionalPhrase(
        'Die Netzprognose basiert auf einer hochauflösenden Zeitreihe.',
      );
      final validVon = engine.validatePrepositionalPhrase(
        'Aufgrund von Netzengpässen mussten zwei Windparks abgeregelt werden.',
      );
      final validVor = engine.validatePrepositionalPhrase(
        'Vor zwei Stunden wurde die neue Software aufgespielt.',
      );
      expect(validBasieren.isValid, isTrue);
      expect(validVon.isValid, isTrue);
      expect(validVor.isValid, isTrue);
    });

    test('UI bridge emits reactive state updates on domain selection and validation', () async {
      final states = <Wave79PrepositionUiState>[];
      final sub = bridge.stateStream.listen(states.add);

      bridge.selectDomain(PrepositionEngineeringDomain.industrialRobotics);
      bridge.submitAttempt('Der Roboter verfügt über einem Drehmomentsensor.');

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states.length, equals(2));
      expect(states.first.selectedDomain,
          equals(PrepositionEngineeringDomain.industrialRobotics));
      expect(states.last.lastValidation?.isValid, isFalse);
      await sub.cancel();
    });
  });
}
