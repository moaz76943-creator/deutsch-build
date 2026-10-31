import 'dart:async';

class SearchResultItem {
  final String term;
  final String gloss;
  final String pairId;

  const SearchResultItem({
    required this.term,
    required this.gloss,
    required this.pairId,
  });
}

/// PairEpochSearchCoordinator - Master Constitution Section 10 Compliant.
/// Prevents stale results from arriving and corrupting the UI state when
/// a user switches language pairs or types a rapid query sequence.
class PairEpochSearchCoordinator {
  String _activePairId = 'de_ar';
  int _activePairEpoch = 0;
  int _activeQueryGeneration = 0;
  bool _isDisposed = false;

  String get activePairId => _activePairId;
  int get activePairEpoch => _activePairEpoch;
  int get activeQueryGeneration => _activeQueryGeneration;
  bool get isDisposed => _isDisposed;

  /// Invoked when the user switches active language pair
  void switchLanguagePair(String newPairId) {
    if (_activePairId != newPairId) {
      _activePairId = newPairId;
      _activePairEpoch++;
      _activeQueryGeneration++; // Invalidate pending queries of prior pair
    }
  }

  /// Dispatches search query. Validates pairEpoch and generation upon completion.
  Future<List<SearchResultItem>?> executeSearch({
    required String query,
    required Future<List<SearchResultItem>> Function(String targetPairId) fetchCandidates,
  }) async {
    if (_isDisposed || query.trim().isEmpty) {
      return <SearchResultItem>[];
    }

    final capturedEpoch = _activePairEpoch;
    final capturedGeneration = ++_activeQueryGeneration;
    final capturedPairId = _activePairId;

    try {
      final results = await fetchCandidates(capturedPairId);

      // Latest-Wins Guard: Discard if pair changed OR newer query was typed in meantime
      if (_isDisposed ||
          capturedEpoch != _activePairEpoch ||
          capturedGeneration != _activeQueryGeneration ||
          capturedPairId != _activePairId) {
        return null; // Stale results dropped
      }

      return results;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _isDisposed = true;
    _activePairEpoch++;
    _activeQueryGeneration++;
  }
}
