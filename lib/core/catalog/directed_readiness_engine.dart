import 'dart:collection';

import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';
import 'package:deutsch_bilarabi/core/catalog/language_readiness_matrix.dart';

enum PairReadinessState {
  ready,
  invalidPair,
  identical,
  unsupportedSource,
  unsupportedTarget,
  missingPack,
  rejectedPack,
  schemaMismatch,
  missingDirectedEvidence,
}

class DirectedPairStatus {
  final PairReadinessState state;
  final String message;
  const DirectedPairStatus(this.state, this.message);

  @override
  bool operator ==(Object other) =>
      other is DirectedPairStatus &&
      other.state == state &&
      other.message == message;

  @override
  int get hashCode => Object.hash(state, message);
}

/// Readiness observation, NOT a replacement for the signed pair admission gate.
/// In particular, a pack gate's "approved" flag alone never proves A->B content.
class DirectedPairReadinessEngine {
  static final RegExp _validLocaleTag =
      RegExp(r'^[a-z]{2,3}(?:-[A-Za-z0-9]{2,8})*$');
  final int maxCachedPairs;
  final int maxCachedPacks;

  final LinkedHashMap<String, LanguagePackGateResult> _packStatusCache =
      LinkedHashMap<String, LanguagePackGateResult>();
  final LinkedHashMap<DirectedPairId, DirectedPairStatus> _pairCache =
      LinkedHashMap<DirectedPairId, DirectedPairStatus>();
  final LinkedHashSet<DirectedPairId> _admittedPairs =
      LinkedHashSet<DirectedPairId>();

  DirectedPairReadinessEngine({
    this.maxCachedPairs = 100,
    this.maxCachedPacks = 100,
  }) {
    if (maxCachedPairs <= 0 || maxCachedPacks <= 0) {
      throw ArgumentError('Cache capacities must be positive');
    }
  }

  DirectedPairStatus resolvePair(DirectedPairId pair) {
    if (pair.isReflexive) {
      return const DirectedPairStatus(
        PairReadinessState.identical, 'Same language',
      );
    }
    if (!pair.isValidForLearning()) {
      return const DirectedPairStatus(
        PairReadinessState.invalidPair, 'Invalid pair identity',
      );
    }
    final cached = _pairCache.remove(pair);
    if (cached != null) {
      _pairCache[pair] = cached;
      return cached;
    }
    final status = _evaluate(pair);
    _pairCache[pair] = status;
    if (_pairCache.length > maxCachedPairs) {
      _pairCache.remove(_pairCache.keys.first);
    }
    return status;
  }

  DirectedPairStatus _evaluate(DirectedPairId pair) {
    if (pair.isReflexive) {
      return const DirectedPairStatus(PairReadinessState.identical, 'Same language');
    }
    if (!pair.isValidForLearning()) {
      return const DirectedPairStatus(PairReadinessState.invalidPair, 'Invalid pair identity');
    }
    if (LanguageReadinessMatrix.getTier(pair.sourceLocale) !=
        LanguageReadinessTier.productionReady) {
      return const DirectedPairStatus(PairReadinessState.unsupportedSource, 'Source not production-ready');
    }
    if (LanguageReadinessMatrix.getTier(pair.targetLocale) !=
        LanguageReadinessTier.productionReady) {
      return const DirectedPairStatus(PairReadinessState.unsupportedTarget, 'Target not production-ready');
    }

    final gate = _packStatusCache[pair.targetLocale];
    if (gate == null) {
      return const DirectedPairStatus(PairReadinessState.missingPack, 'Target pack unverified');
    }
    switch (gate.status) {
      case PackGateStatus.missingChecksum:
      case PackGateStatus.rejected:
        return DirectedPairStatus(
          PairReadinessState.rejectedPack, gate.reason ?? 'Pack not admitted',
        );
      case PackGateStatus.schemaMismatch:
        return DirectedPairStatus(
          PairReadinessState.schemaMismatch, gate.reason ?? 'Pack schema mismatch',
        );
      case PackGateStatus.approved:
        if (_admittedPairs.contains(pair)) {
          return const DirectedPairStatus(
            PairReadinessState.ready,
            'Directed pair admitted and verified',
          );
        }
        return const DirectedPairStatus(
          PairReadinessState.missingDirectedEvidence,
          'No independently verified directed-pair admission',
        );
    }
  }

  void admitDirectedPair(DirectedPairId pair) {
    _admittedPairs.add(pair);
    _pairCache.remove(pair);
    if (_admittedPairs.length > maxCachedPairs) {
      _admittedPairs.remove(_admittedPairs.first);
    }
  }

  void revokeDirectedPair(DirectedPairId pair) {
    _admittedPairs.remove(pair);
    _pairCache.remove(pair);
  }

  void updatePackStatus(String locale, LanguagePackGateResult result) {
    if (locale.length > 64 || !_validLocaleTag.hasMatch(locale)) {
      throw ArgumentError.value(locale, 'locale', 'Invalid pack locale');
    }
    _packStatusCache.remove(locale);
    _packStatusCache[locale] = result;
    if (_packStatusCache.length > maxCachedPacks) {
      _packStatusCache.remove(_packStatusCache.keys.first);
    }
    _pairCache.removeWhere(
      (pair, _) => pair.sourceLocale == locale || pair.targetLocale == locale,
    );
  }

  void invalidatePack(String locale) {
    _packStatusCache.remove(locale);
    _pairCache.removeWhere(
      (pair, _) => pair.sourceLocale == locale || pair.targetLocale == locale,
    );
  }

  void clear() {
    _pairCache.clear();
    _packStatusCache.clear();
    _admittedPairs.clear();
  }

  int get currentPairCacheSize => _pairCache.length;
  int get currentPackCacheSize => _packStatusCache.length;
  int get currentAdmittedPairsCount => _admittedPairs.length;
}

