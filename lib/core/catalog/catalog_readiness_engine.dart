import '../architecture/directed_pair_id.dart';
import 'language_pack_gate.dart';
import 'language_readiness_matrix.dart';
import 'dart:collection';

enum PairReadinessState {
  usable,
  unsupportedSource,
  unsupportedTarget,
  identicalLanguages,
  missingPack,
  rejectedPack,
  silentPivotPrevented,
}

class CatalogReadinessEngine {
  final Map<String, LanguagePackGateResult> _admittedPacks = {};

  // Bounded LRU cache to avoid allocating 9,900 pairs in memory.
  final LinkedHashMap<String, PairReadinessState> _evaluatedPairs =
      LinkedHashMap<String, PairReadinessState>();
  final int _maxCacheSize = 100;

  PairReadinessState resolveReadiness(DirectedPairId pair) {
    final cacheKey = pair.uniqueKey;

    if (_evaluatedPairs.containsKey(cacheKey)) {
      final state = _evaluatedPairs[cacheKey]!;
      _evaluatedPairs.remove(cacheKey);
      _evaluatedPairs[cacheKey] = state;
      return state;
    }

    final state = _evaluate(pair);

    _evaluatedPairs[cacheKey] = state;
    if (_evaluatedPairs.length > _maxCacheSize) {
      _evaluatedPairs.remove(_evaluatedPairs.keys.first);
    }

    return state;
  }

  PairReadinessState _evaluate(DirectedPairId pair) {
    if (pair.isReflexive) {
      return PairReadinessState.identicalLanguages;
    }

    final sourceTier = LanguageReadinessMatrix.getTier(pair.sourceLocale);
    if (sourceTier == LanguageReadinessTier.nominal) {
      return PairReadinessState.unsupportedSource;
    }

    final targetTier = LanguageReadinessMatrix.getTier(pair.targetLocale);
    if (targetTier == LanguageReadinessTier.nominal) {
      return PairReadinessState.unsupportedTarget;
    }

    if (sourceTier != LanguageReadinessTier.productionReady &&
        targetTier != LanguageReadinessTier.productionReady) {
      return PairReadinessState.silentPivotPrevented;
    }

    final packResult = _admittedPacks[pair.uniqueKey];
    if (packResult == null) {
      return PairReadinessState.missingPack;
    }

    if (packResult.status != PackGateStatus.approved) {
      return PairReadinessState.rejectedPack;
    }

    return PairReadinessState.usable;
  }

  void registerPack({
    required DirectedPairId pair,
    required String packCode,
    required int wordCount,
    required String? checksum,
  }) {
    final result = LanguagePackAcceptanceGate.evaluatePack(
      packCode: packCode,
      wordCount: wordCount,
      checksum: checksum,
    );

    _admittedPacks[pair.uniqueKey] = result;
    _evaluatedPairs.remove(pair.uniqueKey);
  }

  void unregisterPack(DirectedPairId pair) {
    _admittedPacks.remove(pair.uniqueKey);
    _evaluatedPairs.remove(pair.uniqueKey);
  }
}
