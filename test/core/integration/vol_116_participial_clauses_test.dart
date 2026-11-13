import 'package:test/test.dart';
import '../../../lib/src/core/content/german_participial_clauses_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave48_ui_bridge.dart';

void main() {
  group('Task 4948: German Participial Clauses & Subject Congruence Engine Tests', () {
    late GermanParticipialClausesEngine engine;
    late Vol116Wave48UiBridge uiBridge;

    setUp(() {
      engine = GermanParticipialClausesEngine();
      uiBridge = Vol116Wave48UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich participial entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
    });

    test('Partizip I entries consistently represent simultaneous temporal relations', () {
      final p1Entries = engine.filterByType(ParticipialType.participleOneSimultaneous);
      expect(p1Entries, isNotEmpty);
      for (final item in p1Entries) {
        expect(item.temporalRelation, equals(TemporalRelation.simultaneous));
      }
    });

    test('Partizip II entries consistently represent anterior/perfective relations', () {
      final p2Entries = engine.filterByType(ParticipialType.participleTwoPrior);
      expect(p2Entries, isNotEmpty);
      for (final item in p2Entries) {
        expect(item.temporalRelation, equals(TemporalRelation.anterior));
      }
    });

    test('Engine accurately catalogues and flags dangling modifier pitfalls', () {
      final dangling = engine.filterByStatus(SubjectEquivalenceStatus.danglingSubjectViolation);
      expect(dangling, isNotEmpty);
      for (final item in dangling) {
        expect(item.fullCombinedSentence.startsWith('*'), isTrue);
      }
    });

    test('Validator detects dangling subject discrepancy', () {
      final report = engine.validateConstruction(
        type: ParticipialType.participleTwoPrior,
        explicitMainSubject: 'die Bauingenieure',
        logicalAgentOfPhrase: 'der Pfeiler',
        hasOwnSubjectNoun: false,
      );

      expect(report.isValid, isFalse);
      expect(report.avoidsDanglingModifier, isFalse);
      expect(report.issues, anyElement(contains('Falscher Bezug')));
    });

    test('Validator approves compliant congruent participial phrase', () {
      final report = engine.validateConstruction(
        type: ParticipialType.participleTwoPrior,
        explicitMainSubject: 'die Brennstoffzelle',
        logicalAgentOfPhrase: 'die Brennstoffzelle',
        hasOwnSubjectNoun: false,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('Validator approves valid absolute construction with own noun', () {
      final report = engine.validateConstruction(
        type: ParticipialType.absoluteParticipialConstruction,
        explicitMainSubject: 'das Schiff',
        logicalAgentOfPhrase: 'alle Luken',
        hasOwnSubjectNoun: true,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalParticipialRules'], greaterThanOrEqualTo(16));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setStatusFilter(SubjectEquivalenceStatus.congruentSubject);
      expect(
        uiBridge.currentFilteredList.every((e) => e.equivalenceStatus == SubjectEquivalenceStatus.congruentSubject),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
