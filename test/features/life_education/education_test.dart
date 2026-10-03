import 'package:deutsch_bilarabi/features/life_education/application/family_education_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_education/domain/education_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FamilyEducationMasterOrchestrator', () {
    late FamilyEducationMasterOrchestrator orchestrator;

    setUp(() {
      orchestrator = FamilyEducationMasterOrchestrator.standard();
    });

    test('exposes both required education sub-agents', () {
      expect(orchestrator.daycare.entries, isNotEmpty);
      expect(orchestrator.school.entries, isNotEmpty);
      expect(
        orchestrator.daycare.entries.every(
          (entry) => entry.area == EducationArea.daycare,
        ),
        isTrue,
      );
      expect(
        orchestrator.school.entries.every(
          (entry) => entry.area == EducationArea.school,
        ),
        isTrue,
      );
    });

    test('filters independently by A1/A2, B1, and B2 levels', () {
      for (final level in EducationLevel.values) {
        final results = orchestrator.filter(level: level);

        expect(results, isNotEmpty, reason: 'Missing \${level.label} content');
        expect(results.every((entry) => entry.level == level), isTrue);
      }
    });

    test('keyword search is case-insensitive and supports Arabic', () {
      final german = orchestrator.filter(query: 'HAUSAUFGABEN');
      final arabic = orchestrator.filter(query: 'حساسية');

      expect(german, isNotEmpty);
      expect(
        german.any((entry) => entry.topic == EducationTopic.homework),
        isTrue,
      );
      expect(arabic, isNotEmpty);
      expect(
        arabic.any((entry) => entry.topic == EducationTopic.allergy),
        isTrue,
      );
    });

    test('daycare sub-agent covers the four required daily-life areas', () {
      expect(
        orchestrator.daycare.byTopic(EducationTopic.dropOffPickup),
        isNotEmpty,
      );
      expect(orchestrator.daycare.byTopic(EducationTopic.allergy), isNotEmpty);
      expect(
        orchestrator.daycare.byTopic(EducationTopic.dailyRoutine),
        isNotEmpty,
      );
      expect(
        orchestrator.daycare.byTopic(EducationTopic.careTimes),
        isNotEmpty,
      );
    });

    test('school sub-agent covers absence, conferences, and homework', () {
      expect(
        orchestrator.school.byTopic(EducationTopic.sickLeave),
        isNotEmpty,
      );
      expect(
        orchestrator.school.byTopic(EducationTopic.parentTeacherConference),
        isNotEmpty,
      );
      expect(
        orchestrator.school.byTopic(EducationTopic.homework),
        isNotEmpty,
      );
    });

    test('emergency absence bar provides appropriate German notices', () {
      final daycare = orchestrator.emergencyAbsence(EducationArea.daycare);
      final school = orchestrator.emergencyAbsence(EducationArea.school);

      expect(daycare.germanText, contains('Kita'));
      expect(daycare.isFormal, isFalse);
      expect(school.germanText, contains('hiermit entschuldige ich'));
      expect(school.germanText, contains('Mit freundlichen Grüßen'));
      expect(school.isFormal, isTrue);
    });

    test('school sick-leave template keeps the formal Sie register', () {
      final sickLeave =
          orchestrator.school.byTopic(EducationTopic.sickLeave).first;

      expect(sickLeave.germanText, contains('Sehr geehrte'));
      expect(sickLeave.germanText, contains('Mit freundlichen Grüßen'));
      expect(sickLeave.formalRegister, isTrue);
    });
  });
}
