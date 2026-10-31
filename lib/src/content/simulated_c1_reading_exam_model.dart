import 'simulated_a1_reading_exam_model.dart';

/// Simulated C1 Reading section assessing complex academic treatises and nuanced epistemological essays.
class SimulatedC1ReadingExamModel {
  static const String c1TextStimulus =
      'Erkenntnistheoretische Reflexionen über künstliche Intelligenz:\n'
      'Die rasanten Fortschritte neuro-symbolischer Sprachmodelle werfen fundamentale '
      'erkenntnistheoretische Fragestellungen auf. Während statistische Korrelationen auf '
      'Milliardenebene verblüffende Sprachkompetenz simulieren, bleibt das genuine Verstehen '
      'semantischer Intentionen an verkörperte, intersubjektive Lebenserfahrungen gebunden. '
      'Ein wahrhaft souveräner Umgang mit künstlicher Intelligenz setzt daher voraus, '
      'technologische Artefakte als epistemische Werkzeuge zu begreifen, nicht als '
      'autonome Subjekte menschlicher Urteilskraft.';

  static const List<ReadingQuestionItem> c1Questions = [
    ReadingQuestionItem(
      questionNumber: 1,
      promptText: 'Woran bleibt genuines semantisches Verstehen laut dem Essay gebunden?',
      options: [
        'An die reine Rechenleistung von Servern',
        'An verkörperte und intersubjektive menschliche Lebenserfahrungen',
        'Ausschließlich an grammatikalische Regelwerke',
      ],
      correctOptionIndex: 1,
      explanationAr: 'النص الأكاديمي يقرر: bleibt das genuine Verstehen semantischer Intentionen an verkörperte, intersubjektive Lebenserfahrungen gebunden.',
    ),
    ReadingQuestionItem(
      questionNumber: 2,
      promptText: 'Wie sollten technologische Artefakte der KI verstanden werden?',
      options: [
        'Als epistemische Werkzeuge, nicht als autonome Subjekte',
        'Als fehlerfreie Richter über menschliche Angelegenheiten',
        'Als reine Unterhaltungsmedien ohne wissenschaftliche Relevanz',
      ],
      correctOptionIndex: 0,
      explanationAr: 'المؤلف يؤكد في ختام النص: technologische Artefakte als epistemische Werkzeuge zu begreifen, nicht als autonome Subjekte.',
    ),
  ];

  /// Scores C1 reading.
  Map<String, dynamic> scoreC1Reading(List<int> answers) {
    if (answers.length != c1Questions.length) return {'isComplete': false, 'score': 0.0};
    int correct = 0;
    for (int i = 0; i < c1Questions.length; i++) {
      if (answers[i] == c1Questions[i].correctOptionIndex) correct++;
    }
    final pct = (correct / c1Questions.length) * 100.0;
    return {
      'isComplete': true,
      'scorePercentage': pct,
      'isPassed': pct >= 60.0,
    };
  }
}
