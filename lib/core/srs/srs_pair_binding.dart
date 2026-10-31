import 'dart:async';

/// Represents an atomic SRS review bound immutably to a specific language pair
class SrsReviewEntry {
  final String pairId;
  final String cardId;
  final int rating;
  final DateTime timestamp;

  const SrsReviewEntry({
    required this.pairId,
    required this.cardId,
    required this.rating,
    required this.timestamp,
  });
}

/// Isolated Pair-Safe SRS Store preventing cross-pair leakage during active pair switching
class SafePairSrsStore {
  final Map<String, List<SrsReviewEntry>> _pairBuckets = {};
  Future<void> _writeChain = Future.value();

  String currentActivePair = 'de_ar';

  /// Saves review ensuring pairId is bound to the review instance, never the mutable active pair
  Future<void> saveReview(SrsReviewEntry review) {
    final completer = Completer<void>();
    _writeChain = _writeChain.then((_) async {
      try {
        // Asynchronous persistence simulation
        await Future.delayed(const Duration(milliseconds: 10));
        _pairBuckets.putIfAbsent(review.pairId, () => []).add(review);
        completer.complete();
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  List<SrsReviewEntry> getReviewsForPair(String pairId) {
    return List.unmodifiable(_pairBuckets[pairId] ?? []);
  }
}
