import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_complex_relative_clauses_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave73_ui_bridge.dart';

void main() {
  group('ComplexRelativeClauseEngine & Wave73UiBridge Tests (Task #4973)', () {
    late ComplexRelativeClauseEngine engine;
    late Vol116Wave73UiBridge bridge;

    setUp(() {
      engine = ComplexRelativeClauseEngine();
      bridge = Vol116Wave73UiBridge(engine: engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('covers all 6 engineering domains with 16+ C1-C2 exemplars', () {
      expect(engine.allExemplars.length, greaterThanOrEqualTo(16));
      for (final domain in EngineeringRelativeDomain.values) {
        expect(engine.getByDomain(domain), isNotEmpty,
            reason: 'Domain $domain should have at least one exemplar');
      }
    });

    test('detects illegal article after genitive relative pronoun dessen/deren', () {
      final result = engine.validateRelativeSentence(
        'Der Wechselrichter, dessen der Wirkungsgrad hoch ist, arbeitet stabil.',
        antecedentIsConcreteNoun: true,
        antecedentIsIndefiniteOrClause: false,
      );
      expect(result.isValid, isFalse);
      expect(result.correctedSuggestion, contains('dessen Wirkungsgrad'));
      expect(engine.telemetry.caughtGenitiveArticleErrors, equals(1));
    });

    test('detects wo(r)- misuse with concrete noun antecedents', () {
      final result = engine.validateRelativeSentence(
        'Der Lasersensor, womit die Naht gemessen wird, arbeitet präzise.',
        antecedentIsConcreteNoun: true,
        antecedentIsIndefiniteOrClause: false,
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtWoRConcreteErrors, equals(1));
    });

    test('detects das instead of was after indefinite pronouns and superlatives', () {
      final result = engine.validateRelativeSentence(
        'Alles, das die Festigkeit mindert, wird entfernt.',
        antecedentIsConcreteNoun: false,
        antecedentIsIndefiniteOrClause: true,
      );
      expect(result.isValid, isFalse);
      expect(result.correctedSuggestion, contains('Alles, was'));
      expect(engine.telemetry.caughtWasDasMismatches, equals(1));
    });

    test('accepts valid C2 prepositional genitive and whole-clause wo(r)- sentences', () {
      final validGen = engine.validateRelativeSentence(
        'Das Tragwerk, auf dessen Basis die Brücke berechnet wurde, ist stabil.',
        antecedentIsConcreteNoun: true,
        antecedentIsIndefiniteOrClause: false,
      );
      final validWoR = engine.validateRelativeSentence(
        'Der Tiefgang wurde überwacht, wodurch Schäden verhindert wurden.',
        antecedentIsConcreteNoun: false,
        antecedentIsIndefiniteOrClause: true,
      );
      expect(validGen.isValid, isTrue);
      expect(validWoR.isValid, isTrue);
    });

    test('UI bridge emits reactive state updates on domain selection and validation', () async {
      final states = <Wave73RelativeUiState>[];
      final sub = bridge.stateStream.listen(states.add);

      bridge.selectDomain(EngineeringRelativeDomain.aerospaceAndAviation);
      bridge.submitAttempt(
        'Die Turbine, deren die Schaufeln aus Titan bestehen, läuft ruhig.',
        antecedentIsConcreteNoun: true,
        antecedentIsIndefiniteOrClause: false,
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states.length, equals(2));
      expect(states.first.selectedDomain, equals(EngineeringRelativeDomain.aerospaceAndAviation));
      expect(states.last.lastValidation?.isValid, isFalse);
      await sub.cancel();
    });
  });
}
