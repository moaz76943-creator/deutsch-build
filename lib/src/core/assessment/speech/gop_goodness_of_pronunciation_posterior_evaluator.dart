/// Task 1421: Goodness of Pronunciation (GOP) acoustic posterior evaluator
class GopEvaluator {
  double computeGop(double acousticScore, double normalizer) => (acousticScore - normalizer).clamp(-10.0, 0.0);
}
