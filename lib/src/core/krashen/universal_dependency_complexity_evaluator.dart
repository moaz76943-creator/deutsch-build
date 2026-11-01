class UniversalDependencyComplexityEvaluator {
  const UniversalDependencyComplexityEvaluator();

  int evaluateDepth(List<int> headIds) {
    int maxDepth = 0;
    for (int i = 0; i < headIds.length; i++) {
      int d = 0, curr = headIds[i];
      while (curr > 0 && curr <= headIds.length && d < 10) {
        d++;
        curr = headIds[curr - 1];
      }
      if (d > maxDepth) maxDepth = d;
    }
    return maxDepth;
  }
}
