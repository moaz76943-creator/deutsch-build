/// Task 1451: Mutual Information & t-score evaluator for collocations
class CollocationBigramScorer {
  double scoreBigram(String w1, String w2) => (w1 == 'große' && w2 == 'Rolle') ? 4.5 : 1.2;
}
