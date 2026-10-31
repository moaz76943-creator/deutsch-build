import 'package:test/test.dart';
import '../../lib/src/content/a2_b1_work_careers_bank.dart';

void main() {
  group('A2B1WorkCareersBank Unit Tests (L009)', () {
    test('Contains professional career vocabulary emphasizing work ethics', () {
      expect(A2B1WorkCareersBank.careerEntries.length, greaterThanOrEqualTo(6));

      final interview = A2B1WorkCareersBank.careerEntries.firstWhere((e) => e.germanWord == 'das Vorstellungsgespräch');
      expect(interview.arabicMeaning, contains('مقابلة العمل'));

      final integrity = A2B1WorkCareersBank.careerEntries.firstWhere((e) => e.germanWord == 'die Zuverlässigkeit');
      expect(integrity.exampleSentenceAr, contains('الأمانة والموثوقية'));
    });
  });
}
