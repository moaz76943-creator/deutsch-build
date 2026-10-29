import '../architecture/directed_pair_id.dart';
import 'language_pack_gate.dart';
import 'language_readiness_matrix.dart';

enum UnavailableReason {
  identicalLanguages,
  unsupportedSource,
  unsupportedTarget,
  silentPivotPrevented,
  targetMissingPack,
  targetPackRejected,
}

abstract class PairReadinessState {}

class PairUsable extends PairReadinessState {}

class PairUnavailable extends PairReadinessState {
  final UnavailableReason reason;
  final String? details;

  PairUnavailable(this.reason, [this.details]);
}

class LanguageNodeState {
  final String code;
  bool isRegistered = false;
  LanguagePackGateResult? packVerification;

  LanguageNodeState(this.code);
}

class DirectedCatalogReadiness {
  final Map<String, LanguageNodeState> _nodes = {};

  void registerLanguage(String code) {
    _nodes.putIfAbsent(code, () => LanguageNodeState(code)).isRegistered = true;
  }

  void markInstalled(String code, int wordCount, String checksum) {
    final node = _nodes.putIfAbsent(code, () => LanguageNodeState(code));
    node.packVerification = LanguagePackAcceptanceGate.evaluatePack(
      packCode: code,
      wordCount: wordCount,
      checksum: checksum,
    );
  }

  void invalidatePack(String code) {
    if (_nodes.containsKey(code)) {
      _nodes[code]!.packVerification = null;
    }
  }

  PairReadinessState resolvePairStatus(DirectedPairId pair) {
    if (pair.isReflexive) {
      return PairUnavailable(UnavailableReason.identicalLanguages);
    }

    final sourceNode = _nodes[pair.sourceLocale];
    if (sourceNode == null || !sourceNode.isRegistered) {
      return PairUnavailable(UnavailableReason.unsupportedSource);
    }

    final targetNode = _nodes[pair.targetLocale];
    if (targetNode == null || !targetNode.isRegistered) {
      return PairUnavailable(UnavailableReason.unsupportedTarget);
    }

    // A silent pivot is when neither source nor target are production ready (like the primary language 'de' or 'ar')
    // and we implicitly try to translate es -> fr by going es -> de -> fr.
    // If BOTH source and target are not production ready, we block it.
    // If AT LEAST ONE is production ready (e.g. es -> de OR de -> es), it's a valid direct pair or reverse pair.
    if (LanguageReadinessMatrix.getTier(pair.sourceLocale) != LanguageReadinessTier.productionReady &&
        LanguageReadinessMatrix.getTier(pair.targetLocale) != LanguageReadinessTier.productionReady) {
      return PairUnavailable(
        UnavailableReason.silentPivotPrevented,
        'Neither source (${pair.sourceLocale}) nor target (${pair.targetLocale}) is a production-ready anchor language'
      );
    }

    final packResult = targetNode.packVerification;
    if (packResult == null) {
      return PairUnavailable(UnavailableReason.targetMissingPack);
    }

    if (packResult.status != PackGateStatus.approved) {
      return PairUnavailable(UnavailableReason.targetPackRejected, packResult.reason);
    }

    return PairUsable();
  }
}
