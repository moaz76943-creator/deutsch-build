import '../architecture/directed_pair_id.dart';
import 'language_pack_gate.dart';
import 'language_readiness_matrix.dart';
import 'canonical_language_catalog.dart';
import 'language_pair_readiness.dart';
import 'dart:collection';

abstract class DirectedPairReadiness {
  final PairReadinessState state;
  const DirectedPairReadiness(this.state);
}

class ReadinessUsable extends DirectedPairReadiness {
  const ReadinessUsable() : super(PairReadinessState.usable);
}

abstract class ReadinessUnavailable extends DirectedPairReadiness {
  final String reason;
  const ReadinessUnavailable(super.state, this.reason);
}

class ReadinessUnsupported extends ReadinessUnavailable {
  const ReadinessUnsupported(String reason)
      : super(PairReadinessState.unsupported, reason);
}

class ReadinessReflexive extends ReadinessUnavailable {
  const ReadinessReflexive()
      : super(PairReadinessState.reflexive, 'Source and target languages cannot be identical.');
}

class ReadinessRegistered extends ReadinessUnavailable {
  const ReadinessRegistered(String reason)
      : super(PairReadinessState.registered, reason);
}

class ReadinessVerified extends ReadinessUnavailable {
  const ReadinessVerified(String reason)
      : super(PairReadinessState.verified, reason);
}

class ReadinessInstalled extends ReadinessUnavailable {
  const ReadinessInstalled(String reason)
      : super(PairReadinessState.installed, reason);
}

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
    if (sourceId.status.name == 'unknown' || sourceId.status.name == 'reviewRequired') {
      return ReadinessUnsupported('Source language metadata not found: ${pair.sourceLocale}');
    }

    final targetId = catalog.resolvePersistedId(pair.targetLocale);
    if (targetId.status.name == 'unknown' || targetId.status.name == 'reviewRequired') {
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

    final record = _admittedPacks[pair.uniqueKey];
    if (record == null) {
      return const ReadinessRegistered('Pack is not admitted yet.');
    }

    if (record.result.status != PackGateStatus.approved) {
      return ReadinessRegistered('Pack rejected: ${record.result.reason}');
    }

    if (!record.isInstalled) {
      return const ReadinessVerified('Pack is verified but not installed.');
    }

    if (!record.isUsable) {
      return const ReadinessInstalled('Pack is installed but not usable.');
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

    _admittedPacks[pair.uniqueKey] = PackRecord(result);
    _evaluatedPairs.remove(pair.uniqueKey);
  }

  void markPackInstalled(DirectedPairId pair) {
    final record = _admittedPacks[pair.uniqueKey];
    if (record != null) {
      _admittedPacks[pair.uniqueKey] = PackRecord(
        record.result,
        isInstalled: true,
        isUsable: record.isUsable,
      );
      _evaluatedPairs.remove(pair.uniqueKey);
    }
  }

  void markPackUsable(DirectedPairId pair) {
    final record = _admittedPacks[pair.uniqueKey];
    if (record != null) {
      _admittedPacks[pair.uniqueKey] = PackRecord(
        record.result,
        isInstalled: true,
        isUsable: true,
      );
      _evaluatedPairs.remove(pair.uniqueKey);
    }
  }

  void invalidatePack(DirectedPairId pair) {
    _admittedPacks.remove(pair.uniqueKey);
    _evaluatedPairs.remove(pair.uniqueKey);
  }
}
