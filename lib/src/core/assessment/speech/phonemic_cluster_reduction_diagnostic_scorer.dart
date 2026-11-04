/// Task 1431: Identifies and scores consonant cluster reductions ('Herbst', 'Pflanze')
class ClusterReductionScorer {
  double scoreCluster(String targetCluster, String detectedCluster) => targetCluster == detectedCluster ? 100.0 : (detectedCluster.length / targetCluster.length) * 80.0;
}
