import '../architecture/directed_pair_id.dart';
import 'language_pack_gate.dart';
import 'language_readiness_matrix.dart';
import 'dart:collection';

enum UnavailableReason {
  unsupportedSource,
  unsupportedTarget,
  identicalLanguages,
  missingPack,
  rejectedPack,
  silentPivotPrevented,
}

abstract class PairReadinessState {}

class PairUsable extends PairReadinessState {}

class UnsupportedSourceState extends PairReadinessState {
  final UnavailableReason reason = UnavailableReason.unsupportedSource;
}

class UnsupportedTargetState extends PairReadinessState {
  final UnavailableReason reason = UnavailableReason.unsupportedTarget;
}

class IdenticalPairState extends PairReadinessState {
  final UnavailableReason reason = UnavailableReason.identicalLanguages;
}

class MissingPackState extends PairReadinessState {
  final UnavailableReason reason = UnavailableReason.missingPack;
}

class RejectedPackState extends PairReadinessState {
  final UnavailableReason reason = UnavailableReason.rejectedPack;
}

class SilentPivotPreventedState extends PairReadinessState {
  final UnavailableReason reason = UnavailableReason.silentPivotPrevented;
}

class CatalogReadinessEngine {
  // To keep catalog state O(N), track admitted packs by targetLocale
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
      return IdenticalPairState();
    }

    final sourceTier = LanguageReadinessMatrix.getTier(pair.sourceLocale);
    if (sourceTier == LanguageReadinessTier.nominal) {
      return UnsupportedSourceState();
    }

    final targetTier = LanguageReadinessMatrix.getTier(pair.targetLocale);
    if (targetTier == LanguageReadinessTier.nominal) {
      return UnsupportedTargetState();
    }

    if (sourceTier != LanguageReadinessTier.productionReady &&
        targetTier != LanguageReadinessTier.productionReady) {
      return SilentPivotPreventedState();
    }

    // Since pack installation depends only on target language
    final packResult = _admittedPacks[pair.targetLocale];
    if (packResult == null) {
      return MissingPackState();
    }

    if (packResult.status != PackGateStatus.approved) {
      return RejectedPackState();
    }

    return PairUsable();
  }

  void registerPack({
    required String targetLocale,
    required String packCode,
    required int wordCount,
    required String? checksum,
  }) {
    final result = LanguagePackAcceptanceGate.evaluatePack(
      packCode: packCode,
      wordCount: wordCount,
      checksum: checksum,
    );

    _admittedPacks[targetLocale] = result;

    // Invalidate affected cache items (any pair with this targetLocale)
    _evaluatedPairs.removeWhere((key, _) {
      try {
        final pair = DirectedPairId.parse(key);
        return pair.targetLocale == targetLocale;
      } catch (_) {
        return false;
      }
    });
  }

  void unregisterPack(String targetLocale) {
    _admittedPacks.remove(targetLocale);

    // Invalidate affected cache items
    _evaluatedPairs.removeWhere((key, _) {
      try {
        final pair = DirectedPairId.parse(key);
        return pair.targetLocale == targetLocale;
      } catch (_) {
        return false;
      }
    });
  }
}
