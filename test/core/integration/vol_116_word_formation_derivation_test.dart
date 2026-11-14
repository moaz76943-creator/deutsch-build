import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_word_formation_derivation_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave83_ui_bridge.dart';

void main() {
  group('GermanWordFormationDerivationEngine & Wave83UiBridge Tests (Task #4983)', () {
    late GermanWordFormationDerivationEngine engine;
    late Vol116Wave83UiBridge bridge;

    setUp(() {
      engine = GermanWordFormationDerivationEngine();
      bridge = Vol116Wave83UiBridge(engine: engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('covers all 6 engineering domains with 16+ C1-C2 exemplars', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final domain in DerivationEngineeringDomain.values) {
        expect(engine.getByDomain(domain), isNotEmpty,
            reason: 'Domain $domain should have at least one exemplar');
      }
      expect(engine.catalog.first.toJson()['id'], equals('wform_01'));
    });

    test('detects wrong gender on -ung / -keit / -heit / -tät nouns', () {
      final result = engine.validateWordFormation(
        'Der Kalibrierung des Höhenmessers dauerte dreißig Minuten.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtGenderSuffixErrors, equals(1));
    });

    test('detects single-s plural error on -nis nouns', () {
      final result = engine.validateWordFormation(
        'Die Messergebnise bestätigen die Integrität des Rumpfs.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtNisPluralErrors, equals(1));
    });

    test('detects redundant preposition über after be- transitivized verb besprechen', () {
      final result = engine.validateWordFormation(
        'Die Ingenieure besprechen über die neuen Sicherheitsabstände.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtPrefixValencyErrors, equals(1));
    });

    test('accepts valid C1-C2 derivation, pluralization, and be- transitivity', () {
      final validUng = engine.validateWordFormation(
        'Die Kalibrierung des Höhenmessers dauerte dreißig Minuten.',
      );
      final validNis = engine.validateWordFormation(
        'Die Messergebnisse bestätigen die Integrität des Rumpfs.',
      );
      final validBe = engine.validateWordFormation(
        'Die Ingenieure besprechen die neuen Sicherheitsabstände.',
      );
      expect(validUng.isValid, isTrue);
      expect(validNis.isValid, isTrue);
      expect(validBe.isValid, isTrue);
    });

    test('UI bridge emits reactive state updates and telemetry snapshot', () async {
      final states = <Vol116Wave83UiState>[];
      final sub = bridge.stateStream.listen(states.add);

      bridge.filterByDomain(DerivationEngineeringDomain.materialScience);
      bridge.submitAttempt('Die Messergebnise sind fehlerhaft.');

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states.length, equals(2));
      expect(states.first.selectedDomain,
          equals(DerivationEngineeringDomain.materialScience));
      expect(states.last.lastValidation?.isValid, isFalse);
      expect(bridge.telemetrySnapshot['totalExemplars'], equals(16));
      await sub.cancel();
    });
  });
}
