import 'package:test/test.dart';
import '../../lib/src/content/simulated_c1_writing_exam_model.dart';

void main() {
  group('SimulatedC1WritingExamModel Unit Tests (L058)', () {
    final model = SimulatedC1WritingExamModel();

    test('Contains advanced C1 academic essay prompt on digital university teaching', () {
      expect(SimulatedC1WritingExamModel.c1WritingPrompt, contains('Digitalisierung der universitären Lehre'));
      expect(SimulatedC1WritingExamModel.c1WritingPrompt, contains('wissenschaftlich fundierten Text'));
    });

    test('Evaluates compliant C1 essay with high academic register and connectors', () {
      const essay =
          'Die fortschreitende Digitalisierung der universitären Lehre transformiert den akademischen Raum nachhaltig. '
          'Einerseits eröffnet der ortsunabhängige Zugriff auf Vorlesungen und Forschungsdatenbanken beispiellose didaktische '
          'Chancen für internationale Studierende. Folglich wird der Bildungszugang spürbar demokratisiert. '
          'Andererseits belegen wissenschaftliche Untersuchungen, dass der spontane interdisziplinäre Gedankenaustausch '
          'im virtuellen Raum häufig verkümmert. Diesbezüglich ist hervorzuheben, dass Präsenzseminare für die Bildung '
          'kritischer Urteilskraft unersetzlich bleiben. Zusammenfassend lässt sich festhalten, dass hybride Lehrformate '
          'die zukunftsfähigste Synthese darstellen.';

      final report = model.evaluateC1AcademicEssay(essay);
      expect(report['isPassed'], isTrue);
      expect(report['academicScoreOutOf6'], greaterThanOrEqualTo(4));
      expect(report['hasAdvancedConnectors'], isTrue);
    });
  });
}
