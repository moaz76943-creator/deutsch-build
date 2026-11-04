/// Task 1907: Dynamic corpus shard balancer distributing storage
class CorpusShardBalancer {
  int computeOptimalShardSize(int wordCount) => (wordCount / 500).ceil();
}
