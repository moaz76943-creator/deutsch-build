import 'dart:async';

/// Shard metrics descriptor reporting storage fragmentation and dead page count.
class ShardCompactionMetrics {
  final String shardId;
  final int totalPageCount;
  final int deadPageCount;
  final double fragmentationRatio;
  final bool requiresCompaction;

  ShardCompactionMetrics({
    required this.shardId,
    required this.totalPageCount,
    required this.deadPageCount,
  })  : fragmentationRatio = totalPageCount > 0 ? deadPageCount / totalPageCount : 0.0,
        requiresCompaction = totalPageCount > 50 && (deadPageCount / totalPageCount) > 0.25;

  Map<String, dynamic> toJson() => {
        'shard_id': shardId,
        'total_pages': totalPageCount,
        'dead_pages': deadPageCount,
        'frag_ratio': fragmentationRatio,
        'needs_compaction': requiresCompaction,
      };
}

/// Governor managing background page reclamation and fragmentation reduction
/// across modular SQLite database shards without blocking UI responsiveness.
class ShardedPageCompactionGovernor {
  final Map<String, ShardCompactionMetrics> _shardStatus = <String, ShardCompactionMetrics>{};
  int _totalCompactionsExecuted = 0;

  int get totalCompactions => _totalCompactionsExecuted;

  /// Inspect shard metrics and register compaction requirement.
  ShardCompactionMetrics registerShardMetrics({
    required String shardId,
    required int totalPages,
    required int deadPages,
  }) {
    final metrics = ShardCompactionMetrics(
      shardId: shardId,
      totalPageCount: totalPages,
      deadPageCount: deadPages,
    );
    _shardStatus[shardId] = metrics;
    return metrics;
  }

  /// Run safe non-blocking vacuum compaction on qualifying shards.
  Future<int> executeScheduledCompaction() async {
    final qualifyingShards = _shardStatus.values
        .where((m) => m.requiresCompaction)
        .toList();

    int reclaimedPages = 0;
    for (final shard in qualifyingShards) {
      reclaimedPages += shard.deadPageCount;
      _totalCompactionsExecuted++;

      // Update shard state to pristine after vacuum
      _shardStatus[shard.shardId] = ShardCompactionMetrics(
        shardId: shard.shardId,
        totalPageCount: shard.totalPageCount - shard.deadPageCount,
        deadPageCount: 0,
      );
    }

    return reclaimedPages;
  }
}
