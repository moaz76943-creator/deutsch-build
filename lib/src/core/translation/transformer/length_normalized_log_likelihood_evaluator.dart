/// Task 1734: Perplexity and length-normalized sequence log-likelihood
class SequenceLogLikelihoodEvaluator {
  double computePerplexity(double logSum, int length) => length > 0 ? (logSum / length).abs() : 0.0;
}
