enum LeechState { normal, warning, quarantinedLeech }

enum RemediationStrategy {
  morphologicalDecomposition, // تفكيك الكلمة إلى جذر وبادئة
  contextualEnrichment,       // تقديم جملة سياقية واضحة جديدة
  mnemonicScaffold,           // وسيلة ربط وتذكير ذهني
}

class LeechDiagnosis {
  final String cardId;
  final LeechState state;
  final int totalLapses;
  final RemediationStrategy? recommendedStrategy;
  final String explanation;

  const LeechDiagnosis({
    required this.cardId,
    required this.state,
    required this.totalLapses,
    this.recommendedStrategy,
    required this.explanation,
  });
}

/// Offline cognitive engine preventing Retrieval-Induced Forgetting (RIF) and remediating leeches.
/// Based on Anderson & Bjork cognitive interference and quarantine research.
class LeechAndRifQuarantineEngine {
  final int lapseThreshold;
  final int quarantineWindowSize;
  final List<String> _recentCategoryHistory = [];

  LeechAndRifQuarantineEngine({
    this.lapseThreshold = 4,
    this.quarantineWindowSize = 5,
  });

  /// تشخيص حالة البطاقة وتحديد ما إذا أصبحت عالقة (Leech)
  LeechDiagnosis evaluateLeech(String cardId, int lapses) {
    if (lapses >= lapseThreshold) {
      return LeechDiagnosis(
        cardId: cardId,
        state: LeechState.quarantinedLeech,
        totalLapses: lapses,
        recommendedStrategy: RemediationStrategy.morphologicalDecomposition,
        explanation: 'البطاقة عالقة (تكرر نسيانها $lapses مرات). تم تحويلها للعزل الصرفي لتفادي استنزاف الذاكرة.',
      );
    }
    if (lapses == lapseThreshold - 1) {
      return LeechDiagnosis(
        cardId: cardId,
        state: LeechState.warning,
        totalLapses: lapses,
        recommendedStrategy: RemediationStrategy.contextualEnrichment,
        explanation: 'تحذير: اقتراب البطاقة من عتبة التعثر ($lapses مرات نسيان).',
      );
    }
    return LeechDiagnosis(
      cardId: cardId,
      state: LeechState.normal,
      totalLapses: lapses,
      explanation: 'حالة البطاقة طبيعية ومستقرة.',
    );
  }

  /// فحص ما إذا كانت الفئة الدلالية محجورة لمنع التثبيط التنافسي (RIF Quarantine)
  bool isCategoryQuarantined(String semanticCategory) {
    return _recentCategoryHistory.contains(semanticCategory.toLowerCase().trim());
  }

  /// تسجيل الفئة بعد المراجعة لفتح نافذة العزل
  void registerCategoryReview(String semanticCategory) {
    final cat = semanticCategory.toLowerCase().trim();
    _recentCategoryHistory.add(cat);
    if (_recentCategoryHistory.length > quarantineWindowSize) {
      _recentCategoryHistory.removeAt(0);
    }
  }

  /// مسح سجل الجلسة
  void resetSession() {
    _recentCategoryHistory.clear();
  }
}
