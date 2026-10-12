import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';
import 'package:deutsch_bilarabi/core/catalog/language_readiness_matrix.dart';
import 'dart:collection';

enum PairReadinessState {
  ready,
  identical,
  unsupportedSource,
  unsupportedTarget,
  missingPack,
  rejectedPack,
  schemaMismatch,
}

class DirectedPairStatus {
  final PairReadinessState state;
  final String message;

  const DirectedPairStatus(this.state, this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectedPairStatus &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          message == other.message;

  @override
  int get hashCode => state.hashCode ^ message.hashCode;

  @override
  String toString() => 'DirectedPairStatus($state, $message)';
}

/// A lazy readiness-resolution subsystem for the catalog without allocating thousands of persistent language-pair instances.
class DirectedPairReadinessEngine {
  // O(N) cache for local admitted language packs
  final Map<String, LanguagePackGateResult> _packStatusCache = {};

  // Bounded cache for evaluated pair results to prevent memory bloat (e.g. 100 languages = 9900 pairs max, we bound to a reasonable active working set).
  final int _maxCachedPairs = 100;
  final LinkedHashMap<DirectedPairId, DirectedPairStatus> _pairCache = LinkedHashMap<DirectedPairId, DirectedPairStatus>(
    equals: (a, b) => a.uniqueKey == b.uniqueKey,
    hashCode: (a) => a.uniqueKey.hashCode,
  );

  /// Evaluates A->B readiness separately from B->A.
  /// Prevents silent pivots through German or English.
  DirectedPairStatus resolvePair(DirectedPairId pairId) {
    if (_pairCache.containsKey(pairId)) {
      // LRU update
      final status = _pairCache.remove(pairId)!;
      _pairCache[pairId] = status;
      return status;
    }

    final status = _evaluatePair(pairId);

    // Add to bounded cache
    _pairCache[pairId] = status;
    if (_pairCache.length > _maxCachedPairs) {
      _pairCache.remove(_pairCache.keys.first);
    }

    return status;
  }

  DirectedPairStatus _evaluatePair(DirectedPairId pairId) {
    if (pairId.isReflexive) {
      return const DirectedPairStatus(PairReadinessState.identical, 'Source and target languages cannot be identical.');
    }

    // Check unsupported source
    final sourceTier = LanguageReadinessMatrix.getTier(pairId.sourceLocale);
    if (sourceTier == LanguageReadinessTier.nominal) {
      return const DirectedPairStatus(PairReadinessState.unsupportedSource, 'Source language is not supported for production.');
    }

    // Check unsupported target
    final targetTier = LanguageReadinessMatrix.getTier(pairId.targetLocale);
    if (targetTier == LanguageReadinessTier.nominal) {
      return const DirectedPairStatus(PairReadinessState.unsupportedTarget, 'Target language is not supported for production.');
    }

    // Must be production ready (preventing silent pivots or incomplete assets)
    if (sourceTier != LanguageReadinessTier.productionReady) {
      return const DirectedPairStatus(PairReadinessState.unsupportedSource, 'Source language requires full production readiness.');
    }
    if (targetTier != LanguageReadinessTier.productionReady) {
      return const DirectedPairStatus(PairReadinessState.unsupportedTarget, 'Target language requires full production readiness.');
    }

    // Check pack status for target (the language being learned)
    if (!_packStatusCache.containsKey(pairId.targetLocale)) {
      return const DirectedPairStatus(PairReadinessState.missingPack, 'Language pack status is unknown or missing.');
    }

    final packResult = _packStatusCache[pairId.targetLocale]!;
    switch (packResult.status) {
      case PackGateStatus.approved:
        return const DirectedPairStatus(PairReadinessState.ready, 'Pair is ready for production use.');
      case PackGateStatus.missingChecksum:
      case PackGateStatus.rejected:
        return DirectedPairStatus(PairReadinessState.rejectedPack, packResult.reason ?? 'Pack rejected');
      case PackGateStatus.schemaMismatch:
        return DirectedPairStatus(PairReadinessState.schemaMismatch, packResult.reason ?? 'Pack schema mismatch');
    }
  }

  /// Explicit readiness invalidation on pack changes
  void updatePackStatus(String locale, LanguagePackGateResult result) {
    _packStatusCache[locale] = result;
    _invalidatePairsInvolving(locale);
  }

  void invalidatePack(String locale) {
    _packStatusCache.remove(locale);
    _invalidatePairsInvolving(locale);
  }

  void _invalidatePairsInvolving(String locale) {
    // Remove any cached pair that involves this locale as source or target
    _pairCache.removeWhere((pairId, value) {
      return pairId.sourceLocale == locale || pairId.targetLocale == locale;
    });
  }

  // Used for testing state bounds
  int get currentPairCacheSize => _pairCache.length;
  int get currentPackCacheSize => _packStatusCache.length;
}
