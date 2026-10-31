import 'package:test/test.dart';
import '../../lib/src/content/simulated_b2_writing_exam_model.dart';

void main() {
  group('SimulatedB2WritingExamModel Unit Tests (L054)', () {
    final model = SimulatedB2WritingExamModel();

    test('Contains standard B2 formal complaint prompt with strict procedural criteria', () {
      expect(SimulatedB2WritingExamModel.b2FormalComplaintPrompt, contains('förmliche Beschwerde'));
      expect(SimulatedB2WritingExamModel.b2FormalComplaintPrompt, contains('Frist'));
    });

    test('Validates compliant B2 formal email meeting salutation, reference, complaint, solution, deadline', () {
      const email =
          'Sehr geehrte Damen und Herren,\n'
          'bezugnehmend auf meine Buchungsnummer DE-8821 wende ich mich mit einer Beanstandung an Sie. '
          'In den vergangenen zwei Wochen fiel der vertraglich zugesicherte Konversationskurs wiederholt ersatzlos aus. '
          'Als konstruktive Lösung erwarte ich, dass die ausgefallenen Unterrichtsstunden an Wochenendterminen nachgeholt werden '
          'oder eine anteilige Rückerstattung der Kursgebühren erfolgt. '
          'Ich bitte um Ihre schriftliche Stellungnahme bis zum 15. des Monats.\n'
          'Mit freundlichen Grüßen,\n'
          'Ahmad Al-Mansoor';

      final res = model.evaluateB2FormalEmail(email);
      expect(res['isPassed'], isTrue);
      expect(res['criteriaFulfilledCount'], greaterThanOrEqualTo(5));
      expect(res['isLengthValid'], isTrue);
    });
  });
}
