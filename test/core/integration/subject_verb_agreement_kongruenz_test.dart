import 'package:test/test.dart';
import 'package:deutsch_app/src/core/content/german_subject_verb_agreement_kongruenz_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave77_ui_bridge.dart';

void main() {
  group('SubjectVerbAgreementKongruenzEngine & Wave77UiBridge Tests (Task #4977)', () {
    late SubjectVerbAgreementKongruenzEngine engine;
    late Vol116Wave77UiBridge bridge;

    setUp(() {
      engine = SubjectVerbAgreementKongruenzEngine();
      bridge = Vol116Wave77UiBridge(engine: engine);
    });

    tearDown(() async {
      await bridge.dispose();
    });

    test('covers all 6 engineering domains with 16+ C1-C2 exemplars', () {
      expect(engine.allExemplars.length, greaterThanOrEqualTo(16));
      for (final domain in KongruenzEngineeringDomain.values) {
        expect(engine.getByDomain(domain), isNotEmpty,
            reason: 'Domain $domain should have at least one exemplar');
      }
    });

    test('detects singular copula error when das/dies links to plural predicate', () {
      final result = engine.validateKongruenz(
        'Das ist die aktuellen Lastprofile der Umspannwerke.',
        predicateOrRealSubjectIsPlural: true,
      );
      expect(result.isValid, isFalse);
      expect(result.correctedSuggestion, contains('sind'));
      expect(engine.telemetry.caughtCopulaPluralErrors, equals(1));
    });

    test('detects Vorfeld-es singular trap when real post-verbal subject is plural', () {
      final result = engine.validateKongruenz(
        'Es wurde insgesamt zwölf Drucksensoren neu kalibriert.',
        predicateOrRealSubjectIsPlural: true,
      );
      expect(result.isValid, isFalse);
      expect(result.correctedSuggestion, contains('wurden'));
      expect(engine.telemetry.caughtVorfeldEsErrors, equals(1));
    });

    test('detects illegal plural verb after singular subject + samt/nebst/einschließlich', () {
      final result = engine.validateKongruenz(
        'Der Hauptcontroller samt seinen vier Achsen wurden aktualisiert.',
        predicateOrRealSubjectIsPlural: false,
      );
      expect(result.isValid, isFalse);
      expect(engine.telemetry.caughtParentheticalPluralTraps, equals(1));
    });

    test('accepts valid C1-C2 copula plural, Vorfeld-es plural, and parenthetical singular', () {
      final validCopula = engine.validateKongruenz(
        'Das sind die aktuellen Lastprofile der Umspannwerke.',
        predicateOrRealSubjectIsPlural: true,
      );
      final validEs = engine.validateKongruenz(
        'Es wurden zwölf Drucksensoren kalibriert.',
        predicateOrRealSubjectIsPlural: true,
      );
      final validSamt = engine.validateKongruenz(
        'Der Hauptcontroller samt seinen vier Achsen wurde aktualisiert.',
        predicateOrRealSubjectIsPlural: false,
      );
      expect(validCopula.isValid, isTrue);
      expect(validEs.isValid, isTrue);
      expect(validSamt.isValid, isTrue);
    });

    test('UI bridge emits reactive state updates on domain selection and validation', () async {
      final states = <Wave77KongruenzUiState>[];
      final sub = bridge.stateStream.listen(states.add);

      bridge.selectDomain(KongruenzEngineeringDomain.industrialRobotics);
      bridge.submitAttempt(
        'Das ist die neuen Achsenkoordinaten.',
        predicateOrRealSubjectIsPlural: true,
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states.length, equals(2));
      expect(states.first.selectedDomain,
          equals(KongruenzEngineeringDomain.industrialRobotics));
      expect(states.last.lastValidation?.isValid, isFalse);
      await sub.cancel();
    });
  });
}
