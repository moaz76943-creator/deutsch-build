import 'dart:collection';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';
import 'package:deutsch_bilarabi/core/catalog/language_readiness_matrix.dart';

enum PairReadinessState {
  ready,
  unsupportedSource,
  unsupportedTarget,
  identical,
  missingPack,
  rejectedPack,
  schemaMismatch,
}

class ReadinessResult {
  final PairReadinessState state;
  final String? message;
  const ReadinessResult(this.state, [this.message]);
}

class DirectedPairReadinessEngine {
  final Map<String, LanguagePackGateResult> _packStatus = {};

  final int _maxCacheSize = 100;
  final LinkedHashMap<DirectedPairId, ReadinessResult> _pairCache = LinkedHashMap();

  int get currentPackCacheSize => _packStatus.length;
  int get currentPairCacheSize => _pairCache.length;

  void updatePackStatus(String packCode, LanguagePackGateResult status) {
    _packStatus[packCode] = status;
    _invalidateCacheForLanguage(packCode);
  }

  void invalidatePack(String packCode) {
    _packStatus.remove(packCode);
    _invalidateCacheForLanguage(packCode);
  }

  void _invalidateCacheForLanguage(String locale) {
    final keysToRemove = _pairCache.keys
        .where((pair) => pair.sourceLocale == locale || pair.targetLocale == locale)
        .toList();
    for (final key in keysToRemove) {
      _pairCache.remove(key);
    }
  }

  ReadinessResult resolvePair(DirectedPairId pair) {
    if (_pairCache.containsKey(pair)) {
      return _pairCache[pair]!;
    }

    final result = _computeReadiness(pair);

    _pairCache[pair] = result;
    if (_pairCache.length > _maxCacheSize) {
      _pairCache.remove(_pairCache.keys.first);
    }

    return result;
  }

  ReadinessResult _computeReadiness(DirectedPairId pair) {
    if (pair.isReflexive) {
      return const ReadinessResult(PairReadinessState.identical);
    }

    final sourceReady = LanguageReadinessMatrix.isProductionReady(pair.sourceLocale);
    if (!sourceReady) {
       return const ReadinessResult(PairReadinessState.unsupportedSource);
    }

    final targetReady = LanguageReadinessMatrix.isProductionReady(pair.targetLocale);
    if (!targetReady) {
       return const ReadinessResult(PairReadinessState.unsupportedTarget);
    }

    final packResult = _packStatus[pair.targetLocale];
    if (packResult == null) {
      return const ReadinessResult(PairReadinessState.missingPack);
    }

    if (packResult.status == PackGateStatus.schemaMismatch) {
      return const ReadinessResult(PairReadinessState.schemaMismatch);
    }

    if (packResult.status != PackGateStatus.approved) {
      return const ReadinessResult(PairReadinessState.rejectedPack);
    }

    return const ReadinessResult(PairReadinessState.ready);
  }
}
