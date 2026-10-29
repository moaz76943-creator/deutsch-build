import 'dart:collection';
import 'package:deutsch_bilarabi/core/contracts/linguistic_capability.dart';
import 'package:deutsch_bilarabi/core/i18n/language_registry.dart';
import 'language_pack_gate.dart';
import 'language_readiness_matrix.dart';

abstract class PairReadinessState {
  final bool isUsable;
  const PairReadinessState(this.isUsable);
}

class ReadyState extends PairReadinessState {
  const ReadyState() : super(true);
}

abstract class UnavailableState extends PairReadinessState {
  final String reason;
  const UnavailableState(this.reason) : super(false);
}

class IdenticalPairState extends UnavailableState {
  const IdenticalPairState(super.reason);
}

class UnregisteredLanguageState extends UnavailableState {
  const UnregisteredLanguageState(super.reason);
}

class UnverifiedLanguageState extends UnavailableState {
  const UnverifiedLanguageState(super.reason);
}

class MissingPackState extends UnavailableState {
  const MissingPackState(super.reason);
}

class InvalidPackState extends UnavailableState {
  const InvalidPackState(super.reason);
}

class UnsupportedPairState extends UnavailableState {
  const UnsupportedPairState(super.reason);
}

class SilentPivotPreventedState extends UnavailableState {
  const SilentPivotPreventedState(super.reason);
}

class DirectedReadinessEngine {
  final Map<String, LanguagePackGateResult> _packStatus = {};

  // Bounded LRU cache, max 100 items to keep O(N) constraints
  final int _maxCacheSize = 100;
  final LinkedHashMap<LanguagePair, PairReadinessState> _pairCache = LinkedHashMap<LanguagePair, PairReadinessState>();

  /// Deprecated. Maintained for API compatibility. Engine now computes supported pairs lazily.
  @Deprecated('Engine computes supported pairs lazily based on Readiness Matrix.')
  void authorizeDirectedPair(String sourceIso, String targetIso) {}

  void submitPackForEvaluation({
    required String packCode,
    required int wordCount,
    required String? checksum,
  }) {
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
            pair.sourceIso == languageCode || pair.targetIso == languageCode)
        .toList();
    for (final key in keysToRemove) {
      _pairCache.remove(key);
    }
  }

  PairReadinessState evaluatePair(String sourceIso, String targetIso) {
    final pair = LanguagePair(sourceIso: sourceIso, targetIso: targetIso);

    if (_pairCache.containsKey(pair)) {
      final state = _pairCache[pair]!;
      // Move to end for LRU
      _pairCache.remove(pair);
      _pairCache[pair] = state;
      return state;
    }

    final state = _computeReadiness(sourceIso, targetIso);

    _pairCache[pair] = state;
    if (_pairCache.length > _maxCacheSize) {
      // Remove oldest entry
      _pairCache.remove(_pairCache.keys.first);
    }

    return state;
  }

  PairReadinessState _computeReadiness(String sourceIso, String targetIso) {
    if (sourceIso == targetIso) {
      return IdenticalPairState(
          'Source and target languages are identical: $sourceIso');
    }

    final sourceState = _checkLanguageRegistered(sourceIso, 'Source');
    if (sourceState is! ReadyState) return sourceState;

    final targetState = _checkLanguageRegistered(targetIso, 'Target');
    if (targetState is! ReadyState) return targetState;

    // Reject nominal languages
    if (LanguageReadinessMatrix.getTier(sourceIso) == LanguageReadinessTier.nominal) {
       return UnverifiedLanguageState('Source language "$sourceIso" is nominal and not supported.');
    }
    if (LanguageReadinessMatrix.getTier(targetIso) == LanguageReadinessTier.nominal) {
       return UnverifiedLanguageState('Target language "$targetIso" is nominal and not supported.');
    }

    // Check for silent pivot
    if (LanguageReadinessMatrix.getTier(sourceIso) != LanguageReadinessTier.productionReady &&
        LanguageReadinessMatrix.getTier(targetIso) != LanguageReadinessTier.productionReady) {
      return SilentPivotPreventedState('Neither source ($sourceIso) nor target ($targetIso) is a production-ready anchor language');
    }

    // Note: Learning A -> B only requires target pack B to be verified.
    final targetPackState = _checkLanguagePack(targetIso, 'Target');
    if (targetPackState is! ReadyState) return targetPackState;

    return const ReadyState();
  }

  PairReadinessState _checkLanguageRegistered(String iso, String role) {
    if (!LanguageRegistry.supportedLanguages.containsKey(iso.toLowerCase())) {
      return UnregisteredLanguageState(
          '$role language "$iso" is not registered.');
    }
    return const ReadyState();
  }

  PairReadinessState _checkLanguagePack(String iso, String role) {
    final packResult = _packStatus[iso];
    if (packResult == null) {
      return MissingPackState('$role language "$iso" pack is missing.');
    }

    if (packResult.status != PackGateStatus.approved) {
      return InvalidPackState(
          '$role language "$iso" pack is invalid: ${packResult.reason ?? packResult.status.name}');
    }

    return const ReadyState();
  }
}
