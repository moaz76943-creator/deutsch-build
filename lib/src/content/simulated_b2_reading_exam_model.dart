import 'simulated_a1_reading_exam_model.dart';

/// Simulated B2 Reading section assessing analytical comprehension of advanced technological and ecological essays.
class SimulatedB2ReadingExamModel {
  static const String b2ArticleText =
      'Nachhaltige Stadtentwicklung und solare Architektur:\n'
      'Die Transformation europäischer Metropolen hin zu klimaneutralen Quartieren erfordert '
      'nicht nur innovative Baustoffe, sondern ein grundlegendes Umdenken in der urbanen Mobilität. '
      'Moderne Wohnanlagen setzen zunehmend auf dachintegrierte Photovoltaiksysteme, die den Eigenbedarf '
      'an grünem Strom vollständig abdecken und überschüssige Energie in lokale Quartierspeicher einspeisen. '
      'Gleichzeitig belegen Studien, dass begrünte Fassaden das Mikroklima spürbar kühlen und die '
      'Lärmbelastung um bis zu fünf Dezibel verringern können.';

  static const List<ReadingQuestionItem> b2Questions = [
    ReadingQuestionItem(
      questionNumber: 1,
      promptText: 'Welche Doppelfunktion erfüllen moderne Photovoltaikanlagen laut dem Artikel?',
      options: [
        'Sie heizen das Gebäude und reinigen das Wasser',
        'Sie decken den Eigenstrombedarf und speisen Überschüsse in Quartierspeicher ein',
        'Sie ersetzen die Ziegelsteine vollständig',
      ],
      correctOptionIndex: 1,
      explanationAr: 'النص يوضح: decken den Eigenbedarf vollständig ab und speisen überschüssige Energie in Quartierspeicher ein.',
    ),
    ReadingQuestionItem(
      questionNumber: 2,
      promptText: 'Welchen wissenschaftlich belegten Nutzen haben begrünte Gebäudefassaden?',
      options: [
        'Klimakühlung und Lärmminderung um bis zu 5 dB',
        'Höhere Baukosten ohne Mehrwert',
        'Vollständige Isolierung gegen Sonnenlicht',
      ],
      correctOptionIndex: 0,
      explanationAr: 'الدراسات تثبت: kühlen das Mikroklima spürbar und verringern die Lärmbelastung um bis zu fünf Dezibel.',
    ),
  ];

  /// Scores B2 reading.
  Map<String, dynamic> scoreB2Reading(List<int> answers) {
    if (answers.length != b2Questions.length) return {'isComplete': false, 'score': 0.0};
    int correct = 0;
    for (int i = 0; i < b2Questions.length; i++) {
      if (answers[i] == b2Questions[i].correctOptionIndex) correct++;
    }
    final pct = (correct / b2Questions.length) * 100.0;
    return {
      'isComplete': true,
      'scorePercentage': pct,
      'isPassed': pct >= 60.0,
    };
  }
}
