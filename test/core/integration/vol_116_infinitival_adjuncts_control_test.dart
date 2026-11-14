import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/src/core/content/german_infinitival_adjuncts_control_engine.dart';
import 'package:deutsch_app/src/ui/bridges/vol_116_wave72_ui_bridge.dart';

void main() {
  group('Task 4972: German Infinitival Adjuncts & Subject Control Tests', () {
    late GermanInfinitivalAdjunctsControlEngine engine;
    late Vol116Wave72UiBridge bridge;

    setUp(() {
      engine = GermanInfinitivalAdjunctsControlEngine();
      bridge = Vol116Wave72UiBridge(engine: engine);
    });

    tearDown(() {
      bridge.dispose();
    });

    test('Engine initializes complete professional catalog with >= 16 items', () {
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
      for (final item in engine.catalog) {
        expect(item.id, startsWith('INF-4972-'));
        expect(item.subordinatingPhrase.isNotEmpty, isTrue);
        expect(item.fullGermanSentence.isNotEmpty, isTrue);
        expect(item.ungrammaticalDanglingCounterExample.isNotEmpty, isTrue);
        expect(item.finiteClauseAlternative.isNotEmpty, isTrue);
        expect(item.controlRuleGerman.isNotEmpty, isTrue);
        expect(item.controlRuleArabic.isNotEmpty, isTrue);
      }
    });

    test('Engine covers all infinitival adjunct types', () {
      for (final type in InfinitivalAdjunctType.values) {
        final matches = engine.getByType(type);
        expect(matches.isNotEmpty, isTrue, reason: 'Type ${type.name} must have at least one exemplar');
      }
    });

    test('Engine covers all subject control statuses', () {
      for (final status in SubjectControlStatus.values) {
        final matches = engine.getByControlStatus(status);
        expect(matches.isNotEmpty, isTrue, reason: 'Status ${status.name} must have at least one exemplar');
      }
    });

    test('Validation rejects um... zu when subjects diverge', () {
      final invalidRes = engine.validateInfinitivalAdjunct(
        controlStatus: SubjectControlStatus.divergentSubjectsFiniteRequired,
        usesInfinitiveUmOhneStattZu: true, // Illegal subject switch!
        isSeparableVerb: false,
        hasInnerZuInSeparableVerb: true,
        matchesPassiveVoiceWhenSubjectIsPatient: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Subjektkontroll-Verstoß'));
    });

    test('Validation rejects dangling um... zu with impersonal passive', () {
      final invalidRes = engine.validateInfinitivalAdjunct(
        controlStatus: SubjectControlStatus.impersonalPassiveViolation,
        usesInfinitiveUmOhneStattZu: true, // Illegal dangling modifier!
        isSeparableVerb: false,
        hasInnerZuInSeparableVerb: true,
        matchesPassiveVoiceWhenSubjectIsPatient: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Dangling-Modifier-Fehler'));
    });

    test('Validation rejects missing inner "zu" in separable verbs', () {
      final invalidRes = engine.validateInfinitivalAdjunct(
        controlStatus: SubjectControlStatus.identicalActiveSubject,
        usesInfinitiveUmOhneStattZu: true,
        isSeparableVerb: true,
        hasInnerZuInSeparableVerb: false, // Missing inner "zu"!
        matchesPassiveVoiceWhenSubjectIsPatient: true,
      );
      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.issues.first, contains('Morphologie-Fehler'));
    });

    test('Validation approves compliant infinitival adjunct with separable verb', () {
      final validRes = engine.validateInfinitivalAdjunct(
        controlStatus: SubjectControlStatus.identicalActiveSubject,
        usesInfinitiveUmOhneStattZu: true,
        isSeparableVerb: true,
        hasInnerZuInSeparableVerb: true,
        matchesPassiveVoiceWhenSubjectIsPatient: true,
      );
      expect(validRes.isValid, isTrue);
      expect(validRes.syntacticNotes.length, equals(2));
    });

    test('UI Bridge correctly handles reactive streaming and filtering', () async {
      expect(bridge.state.isReady, isTrue);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));

      bridge.filterByType(InfinitivalAdjunctType.finalUmZu);
      expect(bridge.state.selectedType, equals(InfinitivalAdjunctType.finalUmZu));
      expect(
        bridge.state.activeExemplars.every((i) => i.adjunctType == InfinitivalAdjunctType.finalUmZu),
        isTrue,
      );

      bridge.resetFilters();
      expect(bridge.state.selectedType, isNull);
      expect(bridge.state.activeExemplars.length, equals(engine.catalog.length));
    });

    test('Telemetry generation reflects exact domain and adjunct distribution', () {
      final telemetry = engine.generateTelemetrySnapshot();
      expect(telemetry['totalExemplars'], equals(engine.catalog.length));
      expect(telemetry['cefrLevel'], contains('C1-C2'));
      expect(telemetry['separableInnerZuCount'], greaterThanOrEqualTo(5));
    });
  });
}
