/// Task 2041: Federated FSRS memory stability aggregator updating parameters locally
class FederatedFsrsStabilityAggregator {
  double aggregateStability(List<double> peerDeltas) => peerDeltas.isNotEmpty ? peerDeltas.reduce((a, b) => a + b) / peerDeltas.length : 1.0;
}
