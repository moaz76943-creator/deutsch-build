import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_adjective_nominalization_declension_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave75_ui_bridge.dart';

void main() {
  group('AdjectiveNominalizationDeclensionEngine & Wave75UiBridge Tests (Task #4975)', () {
    late AdjectiveNominalizationDeclensionEngine engine;
    late Vol116Wave75UiBridge bridge;

    setUp(() {
      engine = AdjectiveNominalizationDeclensionEngine();
      bridge = Vol116Wave75UiBridge(engine: engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('covers all 6 engineering domains with 16+ C1-C2 exemplars', () {
      expect(engine.allExemplars.length, greaterThanOrEqualTo(16));
      for (final domain in DeclensionEngineeringDomain.values) {
        expect(engine.getByDomain(domain), isNotEmpty,
            reason: 'Domain $domain should have at least one exemplar');
      }
    });

    test('detects strong -e error after alle / beide / sämtliche', () {
      final result = engine.validateDeclension(
        'Sämtliche neue Wechselrichter wurden kalibriert.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtQuantifierDeclensionErrors, equals(1));
    });

    test('detects nominalized adjective ending traps after alles vs. nichts/etwas', () {
      final allesTrap = engine.validateDeclension(
        'Das Protokoll dokumentiert alles Wesentliches.',
      );
      final nichtsTrap = engine.validateDeclension(
        'Bei der Inspektion trat nichts Unvorhergesehene auf.',
      );
      expect(allesTrap.isValid, isFalse);
      expect(nichtsTrap.isValid, isFalse);
      expect(engine.telemetry.caughtIndefiniteNominalErrors, equals(2));
    });

    test('detects -es instead of -en in articleless masculine/neuter genitive', () {
      final result = engine.validateDeclension(
        'Trotz hohes Grundwasserdrucks blieb die Baugrube dicht.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtGenitiveEndingErrors, equals(1));
    });

    test('accepts valid C1-C2 declension across quantifiers, nominalizations, and genitive', () {
      final validWeak = engine.validateDeclension(
        'Sämtliche neuen Wechselrichter wurden kalibriert.',
      );
      final validAlles = engine.validateDeclension(
        'Das Protokoll dokumentiert alles Wesentliche.',
      );
      final validGen = engine.validateDeclension(
        'Trotz hohen Grundwasserdrucks blieb die Baugrube dicht.',
      );
      expect(validWeak.isValid, isTrue);
      expect(validAlles.isValid, isTrue);
      expect(validGen.isValid, isTrue);
    });

    test('UI bridge emits reactive state updates on domain selection and validation', () async {
      final states = <Wave75DeclensionUiState>[];
      final sub = bridge.stateStream.listen(states.add);

      bridge.selectDomain(DeclensionEngineeringDomain.materialScience);
      bridge.submitAttempt('Das Labor dokumentiert alles Wesentliches.');

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states.length, equals(2));
      expect(states.first.selectedDomain, equals(DeclensionEngineeringDomain.materialScience));
      expect(states.last.lastValidation?.isValid, isFalse);
      await sub.cancel();
    });
  });
}
