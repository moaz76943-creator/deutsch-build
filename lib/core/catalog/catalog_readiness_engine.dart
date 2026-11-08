import '../architecture/directed_pair_id.dart';
import 'language_pack_gate.dart';
import 'language_readiness_matrix.dart';
import 'canonical_language_catalog.dart';
import 'language_pair_readiness.dart';
import 'dart:collection';

class PackRecord {
  final LanguagePackGateResult result;
  final bool isInstalled;
  final bool isUsable;

  PackRecord(this.result, {this.isInstalled = false, this.isUsable = false});
}

class CatalogReadinessEngine {
  final CanonicalLanguageCatalog catalog;
  final Map<String, PackRecord> _admittedPacks = {};

  final LinkedHashMap<String, DirectedPairReadiness> _evaluatedPairs =
      LinkedHashMap<String, DirectedPairReadiness>();
  final int _maxCacheSize = 100;

  CatalogReadinessEngine(this.catalog);

  DirectedPairReadiness resolveReadiness(DirectedPairId pair) {
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

  DirectedPairReadiness _evaluate(DirectedPairId pair) {
    if (pair.isReflexive) {
      return const ReadinessReflexive();
    }

    final sourceId = catalog.resolvePersistedId(pair.sourceLocale);
    if (sourceId.status == CatalogIdentityStatus.unknown || sourceId.status == CatalogIdentityStatus.reviewRequired) {
      return ReadinessUnsupported('Source language metadata not found: ${pair.sourceLocale}');
    }

    final targetId = catalog.resolvePersistedId(pair.targetLocale);
    if (targetId.status == CatalogIdentityStatus.unknown || targetId.status == CatalogIdentityStatus.reviewRequired) {
      return ReadinessUnsupported('Target language metadata not found: ${pair.targetLocale}');
    }

    final sourceTier = LanguageReadinessMatrix.getTier(pair.sourceLocale);
    if (sourceTier == LanguageReadinessTier.nominal) {
      return ReadinessUnsupported('Source language is nominal and unsupported: ${pair.sourceLocale}');
    }

    final targetTier = LanguageReadinessMatrix.getTier(pair.targetLocale);
    if (targetTier == LanguageReadinessTier.nominal) {
      return ReadinessUnsupported('Target language is nominal and unsupported: ${pair.targetLocale}');
    }

    if (sourceTier != LanguageReadinessTier.productionReady &&
        targetTier != LanguageReadinessTier.productionReady) {
      return const ReadinessUnsupported('Silent pivot prevented: Neither language is production ready.');
    }

    // In a directed pair source->target, we only strictly need the TARGET pack to be admitted/usable
    // Actually, following the old design let's just check the target pack here:
    final record = _admittedPacks[pair.targetLocale];
    if (record == null) {
      return const ReadinessRegistered('Target pack is not admitted yet.');
    }

    if (record.result.status != PackGateStatus.approved) {
      return ReadinessRegistered('Target pack rejected: ${record.result.reason ?? record.result.status.name}');
    }

    if (!record.isInstalled) {
      return const ReadinessVerified('Target pack is verified but not installed.');
    }

    if (!record.isUsable) {
      return const ReadinessInstalled('Target pack is installed but not usable.');
    }

    return const ReadinessUsable();
  }

  void admitPack({
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

    _admittedPacks[pair.targetLocale] = PackRecord(result);
    // Invalidate cache for any pair involving this pack as a target
    _evaluatedPairs.removeWhere((key, value) => key.contains('_${pair.targetLocale}_'));
  }

  void markPackInstalled(DirectedPairId pair) {
    final record = _admittedPacks[pair.targetLocale];
    if (record != null) {
      _admittedPacks[pair.targetLocale] = PackRecord(
        record.result,
        isInstalled: true,
        isUsable: record.isUsable,
      );
      _evaluatedPairs.removeWhere((key, value) => key.contains('_${pair.targetLocale}_'));
    }
  }

  void markPackUsable(DirectedPairId pair) {
    final record = _admittedPacks[pair.targetLocale];
    if (record != null) {
      _admittedPacks[pair.targetLocale] = PackRecord(
        record.result,
        isInstalled: true,
        isUsable: true,
      );
      _evaluatedPairs.removeWhere((key, value) => key.contains('_${pair.targetLocale}_'));
    }
  }

  void invalidatePack(DirectedPairId pair) {
    _admittedPacks.remove(pair.targetLocale);
    _evaluatedPairs.removeWhere((key, value) => key.contains('_${pair.targetLocale}_'));
  }
}
