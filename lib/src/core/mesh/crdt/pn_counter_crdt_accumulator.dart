import 'dart:math';

/// State-based Positive-Negative Counter (PN-Counter) CRDT.
/// Allows concurrent increments and decrements across distributed offline peers
/// with guaranteed convergence using component-wise maximum merging.
class PnCounterCrdtAccumulator {
  final String localNodeId;
  final Map<String, int> _positiveMatrix = <String, int>{};
  final Map<String, int> _negativeMatrix = <String, int>{};

  PnCounterCrdtAccumulator({required this.localNodeId});

  /// Read the current unified value across all peer contributions.
  int get value {
    final totalPositive = _positiveMatrix.values.fold(0, (sum, val) => sum + val);
    final totalNegative = _negativeMatrix.values.fold(0, (sum, val) => sum + val);
    return totalPositive - totalNegative;
  }

  /// Increment local counter.
  void increment([int step = 1]) {
    if (step <= 0) throw ArgumentError('Step must be positive');
    _positiveMatrix[localNodeId] = (_positiveMatrix[localNodeId] ?? 0) + step;
  }

  /// Decrement local counter.
  void decrement([int step = 1]) {
    if (step <= 0) throw ArgumentError('Step must be positive');
    _negativeMatrix[localNodeId] = (_negativeMatrix[localNodeId] ?? 0) + step;
  }

  /// Export internal state for mesh peer gossip.
  Map<String, Map<String, int>> exportState() => {
        'P': Map<String, int>.from(_positiveMatrix),
        'N': Map<String, int>.from(_negativeMatrix),
      };

  /// Merge incoming peer state using commutative idempotent max function.
  void mergeRemoteState(Map<String, Map<String, int>> remoteState) {
    final remoteP = remoteState['P'] ?? {};
    final remoteN = remoteState['N'] ?? {};

    remoteP.forEach((node, count) {
      _positiveMatrix[node] = max(_positiveMatrix[node] ?? 0, count);
    });

    remoteN.forEach((node, count) {
      _negativeMatrix[node] = max(_negativeMatrix[node] ?? 0, count);
    });
  }
}
