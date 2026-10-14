import 'package:deutsch_bilarabi/core/catalog/language_pack_gate.dart';
import 'package:deutsch_bilarabi/core/catalog/language_readiness_matrix.dart';
import 'package:deutsch_bilarabi/core/catalog/language_pair_readiness.dart';
import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';

class CatalogReadinessEngine {
  final Map<String, LanguagePackGateResult> _packStatusCache = {};

  void invalidatePack(String code) {
    _packStatusCache.remove(code);
  }

  void admitPack(String code, LanguagePackGateResult result) {
    _packStatusCache[code] = result;
  }

  PairReadinessState resolvePairReadiness(DirectedPairId pairId) {
    if (pairId.isReflexive) {
      return PairReadinessState.reflexive;
    }

    final sourceTier = LanguageReadinessMatrix.getTier(pairId.sourceLocale);
    final targetTier = LanguageReadinessMatrix.getTier(pairId.targetLocale);

    final targetStatus = _packStatusCache[pairId.targetLocale];

    // Rejected packs make the pair completely unsupported
    if (targetStatus != null && targetStatus.status == PackGateStatus.rejected) {
      return PairReadinessState.unsupported;
    }

    // A pack that is not approved yet is "registered" (if nominal tier) or "verified" (if asset ready but no pack)
    if (targetStatus == null || targetStatus.status != PackGateStatus.approved) {
      if (sourceTier == LanguageReadinessTier.nominal || targetTier == LanguageReadinessTier.nominal) {
        return PairReadinessState.registered;
      }
      return PairReadinessState.verified;
    }

    // We have an approved pack.
    if (targetTier == LanguageReadinessTier.productionReady && sourceTier == LanguageReadinessTier.productionReady) {
       return PairReadinessState.usable;
    }

    // Otherwise it is installed but not production usable yet.
    return PairReadinessState.installed;
  }
}
