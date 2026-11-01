import 'dart:math' as math;

enum AnomalyCategory { caseEnding, agreement, tenseAspect, wordOrder }

class DiagnosticMiniLesson {
  final String id;
  final String title;
  final String explanation;
  final String incorrectSample;
  final String correctSample;
  final AnomalyCategory category;
  final String languageCode;
  final List<double> vector;

  const DiagnosticMiniLesson({
    required this.id,
    required this.title,
    required this.explanation,
    required this.incorrectSample,
    required this.correctSample,
    required this.category,
    required this.languageCode,
    required this.vector,
  });
}

class GrammaticalAnomalyRetriever {
  final List<DiagnosticMiniLesson> _lessons = [];

  void registerLesson(DiagnosticMiniLesson l) => _lessons.add(l);

  static double _cosine(List<double> a, List<double> b) {
    double dot = 0.0, na = 0.0, nb = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i]; na += a[i] * a[i]; nb += b[i] * b[i];
    }
    return (na == 0 || nb == 0) ? 0.0 : dot / (math.sqrt(na) * math.sqrt(nb));
  }

  List<DiagnosticMiniLesson> diagnose(List<double> errorVector, String lang) {
    final list = _lessons.where((l) => l.languageCode == lang).toList();
    list.sort((a, b) => _cosine(errorVector, b.vector).compareTo(_cosine(errorVector, a.vector)));
    return list.take(3).toList();
  }
}
