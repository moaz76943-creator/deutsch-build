import 'package:test/test.dart';
import '../../lib/src/content/simulated_b1_speaking_exam_model.dart';

void main() {
  group('SimulatedB1SpeakingExamModel Unit Tests (L052)', () {
    test('Contains complete 5-part CEFR B1 presentation structure with ethical nutrition theme', () {
      expect(SimulatedB1SpeakingExamModel.presentationParts.length, equals(5));
      expect(SimulatedB1SpeakingExamModel.presentationParts[0].titleDe, contains('Thema & Struktur'));
      expect(SimulatedB1SpeakingExamModel.presentationParts[1].titleDe, contains('Eigene persönliche Erfahrung'));
      expect(SimulatedB1SpeakingExamModel.presentationParts[2].titleDe, contains('Heimatland'));
      expect(SimulatedB1SpeakingExamModel.presentationParts[3].titleDe, contains('Vor- und Nachteile'));
      expect(SimulatedB1SpeakingExamModel.presentationParts[4].titleDe, contains('Abschluss'));
    });
  });
}
