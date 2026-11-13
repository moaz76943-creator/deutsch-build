import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_n_declension_gender_homonym_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave80_ui_bridge.dart';

void main() {
  group('NDeclensionGenderHomonymEngine & Wave80UiBridge Tests (Task #4980)', () {
    late NDeclensionGenderHomonymEngine engine;
    late Vol116Wave80UiBridge bridge;

    setUp(() {
      engine = NDeclensionGenderHomonymEngine();
      bridge = Vol116Wave80UiBridge(engine: engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('covers all 6 engineering domains with 16+ C1-C2 exemplars', () {
      expect(engine.allExemplars.length, greaterThanOrEqualTo(16));
      for (final domain in MorphologyEngineeringDomain.values) {
        expect(engine.getByDomain(domain), isNotEmpty,
            reason: 'Domain $domain should have at least one exemplar');
      }
    });

    test('detects missing n-Deklination -(e)n endings on weak masculine nouns', () {
      final result = engine.validateMorphology(
        'Die Umlaufbahn des Satellits wurde korrigiert.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtMissingNDeclensionErrors, equals(1));
    });

    test('detects missing -s in mixed genitive nouns (des Funkens / des Gedankens)', () {
      final result = engine.validateMorphology(
        'Die Entstehung eines elektrischen Funken wurde verhindert.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtMixedGenitiveNsErrors, equals(1));
    });

    test('detects gender-homonym semantic errors in technical terms', () {
      final result = engine.validateMorphology(
        'Der maximale Drehmoment wird früh erreicht.',
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtGenderHomonymErrors, equals(1));
    });

    test('accepts valid n-Deklination, mixed -ns genitive, and technical gender homonyms', () {
      final validN = engine.validateMorphology(
        'Die Umlaufbahn des Satelliten wurde korrigiert.',
      );
      final validNs = engine.validateMorphology(
        'Die Entstehung eines elektrischen Funkens wurde verhindert.',
      );
      final validGender = engine.validateMorphology(
        'Das maximale Drehmoment wird früh erreicht.',
      );
      expect(validN.isValid, isTrue);
      expect(validNs.isValid, isTrue);
      expect(validGender.isValid, isTrue);
    });

    test('UI bridge emits reactive state updates on domain selection and validation', () async {
      final states = <Wave80MorphologyUiState>[];
      final sub = bridge.stateStream.listen(states.add);

      bridge.selectDomain(MorphologyEngineeringDomain.materialScience);
      bridge.submitAttempt('Das genaue Kohlenstoffgehalt bestimmt die Härte.');

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states.length, equals(2));
      expect(states.first.selectedDomain,
          equals(MorphologyEngineeringDomain.materialScience));
      expect(states.last.lastValidation?.isValid, isFalse);
      await sub.cancel();
    });
  });
}
