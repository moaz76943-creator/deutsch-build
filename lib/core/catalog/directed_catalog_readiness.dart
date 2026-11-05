import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';
import 'package:deutsch_bilarabi/core/catalog/language_readiness_matrix.dart';
import 'dart:collection';

abstract class PairReadinessResult {}

class PairUsable extends PairReadinessResult {}

class PairUnavailable extends PairReadinessResult {
  final UnavailableReason reason;
  PairUnavailable(this.reason);
}

enum UnavailableReason {
  unsupportedSource,
  identicalLanguages,
  unsupportedTarget,
  silentPivotPrevented,
  targetMissingPack,
  targetPackRejected
}

class DirectedCatalogReadiness {
  final Map<String, bool> _registeredLanguages = {};
  final Map<String, LanguagePackGateResult> _packStatus = {};

  final int _maxCacheSize = 100;
  final LinkedHashMap<DirectedPairId, PairReadinessResult> _pairCache = LinkedHashMap<DirectedPairId, PairReadinessResult>();

  void registerLanguage(String iso) {
    _registeredLanguages[iso.toLowerCase()] = true;
  }

  void markInstalled(String packCode, int wordCount, String checksum) {
    final result = LanguagePackAcceptanceGate.evaluatePack(
      packCode: packCode,
      wordCount: wordCount,
      checksum: checksum,
    );
    _packStatus[packCode] = result;
    _invalidateCacheForLanguage(packCode);
  }

  void invalidatePack(String packCode) {
    if (!_packStatus.containsKey(packCode)) return;
    _packStatus.remove(packCode);
    _invalidateCacheForLanguage(packCode);
  }

  void _invalidateCacheForLanguage(String languageCode) {
    final keysToRemove = _pairCache.keys
        .where((pair) =>
            pair.sourceLocale == languageCode || pair.targetLocale == languageCode)
        .toList();
    for (final key in keysToRemove) {
      _pairCache.remove(key);
    }
  }

  PairReadinessResult resolvePairStatus(DirectedPairId pair) {
    if (_pairCache.containsKey(pair)) {
      final state = _pairCache[pair]!;
      _pairCache.remove(pair);
      _pairCache[pair] = state;
      return state;
    }

    final state = _computeReadiness(pair);

    _pairCache[pair] = state;
    if (_pairCache.length > _maxCacheSize) {
      _pairCache.remove(_pairCache.keys.first);
    }

    return state;
  }

  PairReadinessResult _computeReadiness(DirectedPairId pair) {
    if (pair.isReflexive) {
      return PairUnavailable(UnavailableReason.identicalLanguages);
    }

    if (!_registeredLanguages.containsKey(pair.sourceLocale)) {
      return PairUnavailable(UnavailableReason.unsupportedSource);
    }

    if (!_registeredLanguages.containsKey(pair.targetLocale)) {
      return PairUnavailable(UnavailableReason.unsupportedTarget);
    }

    // Check for silent pivot
    if (LanguageReadinessMatrix.getTier(pair.sourceLocale) != LanguageReadinessTier.productionReady &&
        LanguageReadinessMatrix.getTier(pair.targetLocale) != LanguageReadinessTier.productionReady) {
      return PairUnavailable(UnavailableReason.silentPivotPrevented);
    }

    final targetPackState = _packStatus[pair.targetLocale];
    if (targetPackState == null) {
      return PairUnavailable(UnavailableReason.targetMissingPack);
    }

    if (targetPackState.status != PackGateStatus.approved) {
      return PairUnavailable(UnavailableReason.targetPackRejected);
    }

    return PairUsable();
  }
}
