import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_modal_polysemy_epistemic_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave81_ui_bridge.dart';

void main() {
  group('ModalPolysemyEpistemicEngine & Wave81UiBridge Tests (Task #4981)', () {
    late ModalPolysemyEpistemicEngine engine;
    late Vol116Wave81UiBridge bridge;

    setUp(() {
      engine = ModalPolysemyEpistemicEngine();
      bridge = Vol116Wave81UiBridge(engine: engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('covers all 6 engineering domains with 16+ C1-C2 exemplars', () {
      expect(engine.allExemplars.length, greaterThanOrEqualTo(16));
      for (final domain in ModalEngineeringDomain.values) {
        expect(engine.getByDomain(domain), isNotEmpty,
            reason: 'Domain $domain should have at least one exemplar');
      }
    });

    test('detects missing zu in negated/restricted brauchen construction', () {
      final result = engine.validateModalUsage(
        'Man braucht die Probe nicht vorwärmen.',
        expressesStrictProhibition: false,
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtBrauchenMissingZuErrors, equals(1));
    });

    test('detects muss nicht misuse when strict prohibition (darf nicht) is intended', () {
      final result = engine.validateModalUsage(
        'Die Legierung muss keinesfalls mit Sauerstoff in Kontakt kommen.',
        expressesStrictProhibition: true,
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtNegationPolarityErrors, equals(1));
    });

    test('detects finite auxiliary instead of Infinitiv II in epistemic past deduction', () {
      final result = engine.validateModalUsage(
        'Der Drucksensor muss vor dem Start ausgefallen ist.',
        expressesStrictProhibition: false,
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtEpistemicTenseErrors, equals(1));
    });

    test('accepts valid brauchen + zu, darf nicht prohibition, and epistemic Infinitiv II', () {
      final validBrauchen = engine.validateModalUsage(
        'Man braucht die Probe nicht zusätzlich vorzuwärmen.',
        expressesStrictProhibition: false,
      );
      final validProhibition = engine.validateModalUsage(
        'Die Legierung darf keinesfalls mit Sauerstoff in Kontakt kommen.',
        expressesStrictProhibition: true,
      );
      final validEpistemic = engine.validateModalUsage(
        'Der Drucksensor muss vor dem Start ausgefallen sein.',
        expressesStrictProhibition: false,
      );
      expect(validBrauchen.isValid, isTrue);
      expect(validProhibition.isValid, isTrue);
      expect(validEpistemic.isValid, isTrue);
    });

    test('UI bridge emits reactive state updates on domain selection and validation', () async {
      final states = <Wave81ModalUiState>[];
      final sub = bridge.stateStream.listen(states.add);

      bridge.selectDomain(ModalEngineeringDomain.materialScience);
      bridge.submitAttempt(
        'Man braucht die Probe nicht vorwärmen.',
        expressesStrictProhibition: false,
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states.length, equals(2));
      expect(states.first.selectedDomain,
          equals(ModalEngineeringDomain.materialScience));
      expect(states.last.lastValidation?.isValid, isFalse);
      await sub.cancel();
    });
  });
}
