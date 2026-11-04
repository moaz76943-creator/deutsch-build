/// Task 1494: Scores academic spoken presentations of trends and data
class InfographicPresentationScorer {
  int countTrendKeywords(String speech) => ['steigt', 'sinkt', 'stabil', 'Zuwachs', 'ارتفاع', 'انخفاض'].where((w) => speech.contains(w)).length;
}
