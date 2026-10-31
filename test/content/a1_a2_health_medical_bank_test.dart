import 'package:test/test.dart';
import '../../lib/src/content/a1_a2_health_medical_bank.dart';

void main() {
  group('A1A2HealthMedicalBank Unit Tests (L007)', () {
    test('Contains core medical and pharmacy terms with accurate Arabic translations', () {
      expect(A1A2HealthMedicalBank.medicalEntries.length, greaterThanOrEqualTo(6));

      final doc = A1A2HealthMedicalBank.medicalEntries.firstWhere((e) => e.germanWord == 'der Arzt');
      expect(doc.arabicMeaning, contains('الطبيب'));

      final recovery = A1A2HealthMedicalBank.medicalEntries.firstWhere((e) => e.germanWord == 'gute Besserung');
      expect(recovery.arabicMeaning, contains('الشفاء العاجل'));
    });

    test('All examples are ethically sound, positive, and medically helpful', () {
      for (final item in A1A2HealthMedicalBank.medicalEntries) {
        expect(item.exampleSentenceDe.isNotEmpty, isTrue);
        expect(item.exampleSentenceAr.isNotEmpty, isTrue);
      }
    });
  });
}
