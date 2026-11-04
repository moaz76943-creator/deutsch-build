import '../architecture/directed_pair_id.dart';
import '../i18n/language_registry.dart';
import 'language_pack_gate.dart';
import 'language_readiness_matrix.dart';
import 'dart:collection';

enum UnavailableReason {
  unsupportedSource,
  unsupportedTarget,
  identicalLanguages,
  silentPivotPrevented,
  targetMissingPack,
  targetPackRejected,
}

abstract class PairStatus {}

class PairUsable extends PairStatus {}

class PairUnavailable extends PairStatus {
  final UnavailableReason reason;
  PairUnavailable(this.reason);
}

class DirectedCatalogReadiness {
  final Set<String> _registeredLanguages = {};
  final Map<String, LanguagePackGateResult> _packStatus = {};

  final int _maxCacheSize = 100;
  final LinkedHashMap<String, PairStatus> _pairCache = LinkedHashMap<String, PairStatus>();

  void registerLanguage(String locale) {
    _registeredLanguages.add(locale);
  }

  void markInstalled(String locale, int words, String checksum) {
    final result = LanguagePackAcceptanceGate.evaluatePack(
      packCode: locale,
      wordCount: words,
      checksum: checksum,
    );
    _packStatus[locale] = result;
    _invalidateCacheForLanguage(locale);
  }

  void invalidatePack(String locale) {
    if (!_packStatus.containsKey(locale)) return;
    _packStatus.remove(locale);
    _invalidateCacheForLanguage(locale);
  }

  void _invalidateCacheForLanguage(String languageCode) {
    final keysToRemove = _pairCache.keys
        .where((key) =>
            key.startsWith('${languageCode}_') || key.contains('_${languageCode}_'))
        .toList();
    for (final key in keysToRemove) {
      _pairCache.remove(key);
    }
  }

  PairStatus resolvePairStatus(DirectedPairId pair) {
    final cacheKey = pair.uniqueKey;
    if (_pairCache.containsKey(cacheKey)) {
      final state = _pairCache[cacheKey]!;
      _pairCache.remove(cacheKey);
      _pairCache[cacheKey] = state;
      return state;
    }

    final state = _evaluate(pair);

    _pairCache[cacheKey] = state;
    if (_pairCache.length > _maxCacheSize) {
      _pairCache.remove(_pairCache.keys.first);
    }

    return state;
  }

  PairStatus _evaluate(DirectedPairId pair) {
    if (pair.sourceLocale == pair.targetLocale) {
      return PairUnavailable(UnavailableReason.identicalLanguages);
    }

    if (!_registeredLanguages.contains(pair.sourceLocale) && !LanguageRegistry.supportedLanguages.containsKey(pair.sourceLocale)) {
      return PairUnavailable(UnavailableReason.unsupportedSource);
    }

    if (!_registeredLanguages.contains(pair.targetLocale) && !LanguageRegistry.supportedLanguages.containsKey(pair.targetLocale)) {
      return PairUnavailable(UnavailableReason.unsupportedTarget);
    }

    final sourceTier = LanguageReadinessMatrix.getTier(pair.sourceLocale);
    final targetTier = LanguageReadinessMatrix.getTier(pair.targetLocale);

    if (sourceTier == LanguageReadinessTier.nominal && !_registeredLanguages.contains(pair.sourceLocale)) {
       return PairUnavailable(UnavailableReason.unsupportedSource);
    }
    if (targetTier == LanguageReadinessTier.nominal && !_registeredLanguages.contains(pair.targetLocale)) {
       return PairUnavailable(UnavailableReason.unsupportedTarget);
    }

    if (sourceTier != LanguageReadinessTier.productionReady &&
        targetTier != LanguageReadinessTier.productionReady) {
      return PairUnavailable(UnavailableReason.silentPivotPrevented);
    }

    final packResult = _packStatus[pair.targetLocale];
    if (packResult == null) {
      return PairUnavailable(UnavailableReason.targetMissingPack);
    }

    if (packResult.status != PackGateStatus.approved) {
      return PairUnavailable(UnavailableReason.targetPackRejected);
    }

    return PairUsable();
  }
}
