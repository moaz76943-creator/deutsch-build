class HypotheticalSubjunctiveMoodSelector {
  String buildCounterfactual(String condition, String consequence, String lang) =>
      lang == 'ar' ? 'لو $condition لـ $consequence' : 'Wenn $condition, wäre $consequence';
}
