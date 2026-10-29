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

class DirectedReadinessEngine {
  final Map<String, LanguagePackGateResult> _packStatus = {};
  final Set<LanguagePair> _supportedPairs = {};

  // Bounded cache, max 50 items
  final int _maxCacheSize = 50;
  final LinkedHashMap<LanguagePair, PairReadinessState> _pairCache = LinkedHashMap();

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
    _packStatus.remove(packCode);
    _invalidateCacheForLanguage(packCode);
  }

  void _invalidateCacheForLanguage(String languageCode) {
    final keysToRemove = _pairCache.keys.where((pair) =>
        pair.sourceIso == languageCode || pair.targetIso == languageCode).toList();
    for (final key in keysToRemove) {
      _pairCache.remove(key);
    }
  }

  PairReadinessState evaluatePair(String sourceIso, String targetIso) {
    final pair = LanguagePair(sourceIso: sourceIso, targetIso: targetIso);

    if (_pairCache.containsKey(pair)) {
      return _pairCache[pair]!;
    }

    final state = _computeReadiness(sourceIso, targetIso);

    _pairCache[pair] = state;
    if (_pairCache.length > _maxCacheSize) {
      // Remove oldest entry
      _pairCache.remove(_pairCache.keys.first);
    }

    return state;
  }

  void authorizeDirectedPair(String sourceIso, String targetIso) {
    final pair = LanguagePair(sourceIso: sourceIso, targetIso: targetIso);
    _supportedPairs.add(pair);
    _pairCache.remove(pair); // Invalidate in cache just in case it was cached as unsupported
  }

  PairReadinessState _computeReadiness(String sourceIso, String targetIso) {
    if (sourceIso == targetIso) {
      return IdenticalPairState('Source and target languages are identical: $sourceIso');
    }

    final pair = LanguagePair(sourceIso: sourceIso, targetIso: targetIso);
    if (!_supportedPairs.contains(pair)) {
      return UnsupportedPairState('Directed language pair ${sourceIso} -> ${targetIso} is not authorized for learning.');
    }

    final sourceState = _checkLanguage(sourceIso, 'Source');
    if (sourceState is! ReadyState) return sourceState;

    final targetState = _checkLanguage(targetIso, 'Target');
    if (targetState is! ReadyState) return targetState;

    return const ReadyState();
  }

  PairReadinessState _checkLanguage(String iso, String role) {
    if (!LanguageRegistry.supportedLanguages.containsKey(iso.toLowerCase())) {
      return UnregisteredLanguageState('$role language "$iso" is not registered.');
    }

    if (LanguageReadinessMatrix.getTier(iso) != LanguageReadinessTier.productionReady) {
      return UnverifiedLanguageState('$role language "$iso" is not verified for production.');
    }

    final packResult = _packStatus[iso];
    if (packResult == null) {
      return MissingPackState('$role language "$iso" pack is missing.');
    }

    if (packResult.status != PackGateStatus.approved) {
      return InvalidPackState('$role language "$iso" pack is invalid: ${packResult.reason ?? packResult.status.name}');
    }

    return const ReadyState();
  }
}
