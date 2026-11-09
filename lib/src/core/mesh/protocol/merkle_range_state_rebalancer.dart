import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Range slice bucket containing keys and aggregate SHA-256 state hash.
class MerkleRangeBucket {
  final int bucketIndex;
  final List<String> itemKeys;
  String bucketHashSha256;

  MerkleRangeBucket({
    required this.bucketIndex,
    List<String>? itemKeys,
    this.bucketHashSha256 = '',
  }) : itemKeys = itemKeys ?? <String>[];

  void recomputeHash() {
    if (itemKeys.isEmpty) {
      bucketHashSha256 = 'EMPTY_BUCKET';
      return;
    }
    itemKeys.sort();
    final combined = itemKeys.join('|');
    bucketHashSha256 = sha256.convert(utf8.encode(combined)).toString();
  }
}

/// Slices the key-space into 64 deterministic buckets to synchronize only
/// conflicting data ranges across offline mesh peers without syncing full tables.
class MerkleRangeStateRebalancer {
  final int totalBuckets;
  final List<MerkleRangeBucket> _buckets;

  MerkleRangeStateRebalancer({this.totalBuckets = 64})
      : _buckets = List.generate(
          totalBuckets,
          (i) => MerkleRangeBucket(bucketIndex: i),
        );

  int get bucketCount => totalBuckets;

  /// Hash a key to a specific bucket index (0 .. totalBuckets - 1).
  int _hashToBucket(String key) {
    int hash = 5381;
    for (int i = 0; i < key.length; i++) {
      hash = ((hash << 5) + hash) + key.codeUnitAt(i);
      hash &= 0x7FFFFFFF;
    }
    return hash % totalBuckets;
  }

  /// Insert an entity key into its partitioned bucket.
  void addKey(String key) {
    final idx = _hashToBucket(key);
    _buckets[idx].itemKeys.add(key);
    _buckets[idx].recomputeHash();
  }

  /// Get list of bucket hashes for lightweight initial peer exchange.
  List<String> getSummaryHashes() {
    return _buckets.map((b) {
      if (b.bucketHashSha256.isEmpty) b.recomputeHash();
      return b.bucketHashSha256;
    }).toList();
  }

  /// Compare local summary hashes with remote summary hashes to pinpoint conflicting ranges.
  List<int> identifyMismatchedBucketIndices(List<String> remoteHashes) {
    if (remoteHashes.length != totalBuckets) {
      throw ArgumentError('Remote bucket count mismatch: ${remoteHashes.length} != $totalBuckets');
    }

    final mismatched = <int>[];
    for (int i = 0; i < totalBuckets; i++) {
      if (_buckets[i].bucketHashSha256 != remoteHashes[i]) {
        mismatched.add(i);
      }
    }
    return mismatched;
  }

  List<String> getKeysInBucket(int bucketIndex) {
    if (bucketIndex < 0 || bucketIndex >= totalBuckets) {
      throw RangeError.index(bucketIndex, _buckets);
    }
    return List.unmodifiable(_buckets[bucketIndex].itemKeys);
  }
}
