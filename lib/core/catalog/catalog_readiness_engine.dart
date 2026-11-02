import '../architecture/directed_pair_id.dart';
import 'language_pack_gate.dart';
import 'language_readiness_matrix.dart';
import 'dart:collection';

abstract class PairReadinessState {
  final bool isUsable;
  const PairReadinessState(this.isUsable);
}

class PairUsable extends PairReadinessState {
  const PairUsable() : super(true);
}

abstract class PairUnavailable extends PairReadinessState {
  final String reason;
  const PairUnavailable(this.reason) : super(false);
}

class IdenticalPairState extends PairUnavailable {
  const IdenticalPairState(super.reason);
}

class UnsupportedSourceState extends PairUnavailable {
  const UnsupportedSourceState(super.reason);
}

class UnsupportedTargetState extends PairUnavailable {
  const UnsupportedTargetState(super.reason);
}

class SilentPivotPreventedState extends PairUnavailable {
  const SilentPivotPreventedState(super.reason);
}

class MissingPackState extends PairUnavailable {
  const MissingPackState(super.reason);
}

class RejectedPackState extends PairUnavailable {
  const RejectedPackState(super.reason);
}

class CatalogReadinessEngine {
  final Map<String, LanguagePackGateResult> _admittedPacks = {};

  // Bounded LRU cache to avoid allocating 9,900 pairs in memory.
  final LinkedHashMap<DirectedPairId, PairReadinessState> _evaluatedPairs =
      LinkedHashMap<DirectedPairId, PairReadinessState>();
  final int _maxCacheSize = 100;

  PairReadinessState resolveReadiness(DirectedPairId pair) {
    if (_evaluatedPairs.containsKey(pair)) {
      final state = _evaluatedPairs[pair]!;
      _evaluatedPairs.remove(pair);
      _evaluatedPairs[pair] = state;
      return state;
    }

    final state = _evaluate(pair);

    _evaluatedPairs[pair] = state;
    if (_evaluatedPairs.length > _maxCacheSize) {
      _evaluatedPairs.remove(_evaluatedPairs.keys.first);
    }

    return state;
  }

  PairReadinessState _evaluate(DirectedPairId pair) {
    if (pair.isReflexive) {
      return IdenticalPairState('Identical languages: ${pair.sourceLocale}');
    }

    final sourceTier = LanguageReadinessMatrix.getTier(pair.sourceLocale);
    if (sourceTier == LanguageReadinessTier.nominal) {
      return UnsupportedSourceState('Source language unsupported: ${pair.sourceLocale}');
    }

    final targetTier = LanguageReadinessMatrix.getTier(pair.targetLocale);
    if (targetTier == LanguageReadinessTier.nominal) {
      return UnsupportedTargetState('Target language unsupported: ${pair.targetLocale}');
    }

    if (sourceTier != LanguageReadinessTier.productionReady &&
        targetTier != LanguageReadinessTier.productionReady) {
      return SilentPivotPreventedState('Silent pivot prevented between ${pair.sourceLocale} and ${pair.targetLocale}');
    }

    final packResult = _admittedPacks[pair.targetLocale];
    if (packResult == null) {
      return MissingPackState('Missing pack for target language: ${pair.targetLocale}');
    }

    if (packResult.status != PackGateStatus.approved) {
      return RejectedPackState('Rejected pack for target language: ${pair.targetLocale} - ${packResult.reason ?? packResult.status.name}');
    }

    return const PairUsable();
  }

  void registerPack({
    required String packCode,
    required int wordCount,
    required String? checksum,
  }) {
    final result = LanguagePackAcceptanceGate.evaluatePack(
      packCode: packCode,
      wordCount: wordCount,
      checksum: checksum,
    );

    _admittedPacks[packCode] = result;
    _invalidateCacheForLanguage(packCode);
  }

  void unregisterPack(String packCode) {
    _admittedPacks.remove(packCode);
    _invalidateCacheForLanguage(packCode);
  }

  void _invalidateCacheForLanguage(String languageCode) {
    final keysToRemove = _evaluatedPairs.keys
        .where((pair) => pair.sourceLocale == languageCode || pair.targetLocale == languageCode)
        .toList();
    for (final key in keysToRemove) {
      _evaluatedPairs.remove(key);
    }
  }
}
