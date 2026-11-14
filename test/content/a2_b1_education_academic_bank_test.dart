import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/a2_b1_education_academic_bank.dart';

void main() {
  group('A2B1EducationAcademicBank Unit Tests (L008)', () {
    test('Contains core academic and university vocabulary with inspiring examples', () {
      expect(A2B1EducationAcademicBank.academicEntries.length, greaterThanOrEqualTo(6));

      final uni = A2B1EducationAcademicBank.academicEntries.firstWhere((e) => e.germanWord == 'die Universität');
      expect(uni.arabicMeaning, contains('الجامعة'));

      final science = A2B1EducationAcademicBank.academicEntries.firstWhere((e) => e.germanWord == 'die Wissenschaft');
      expect(science.cefrLevel, equals('B1'));
      expect(science.exampleSentenceAr, contains('العلم'));
    });
  });
}
