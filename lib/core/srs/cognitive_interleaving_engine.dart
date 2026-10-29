enum LearningModality {
  vocabularyRecognition,      // تعرف واستدعاء مفردات
  grammarSyntaxValidation,    // تدقيق قواعد وترتيب جمل
  listeningComprehension,     // فهم مسموع وصوتيات
  activeProduction,           // إنتاج نشط وكتابة
  contrastiveDiscrimination,  // تمييز الفروق الدقيقة والمشتتات
}

class InterleavedReviewItem {
  final String itemId;
  final LearningModality modality;
  final double overduePriority; // أولوية الاستحقاق الزمني في FSRS-5

  const InterleavedReviewItem({
    required this.itemId,
    required this.modality,
    required this.overduePriority,
  });
}

/// Offline cognitive engine preventing blocked practice by interleaving disparate linguistic modalities.
/// Based on Bjork & Rohrer "Desirable Difficulties" and inductive category contrast research.
class CognitiveInterleavingEngine {
  final int maxConsecutiveModality;

  const CognitiveInterleavingEngine({this.maxConsecutiveModality = 2});

  /// إعادة تنظيم طابور المراجعات لمنع التتابع المفرط لنفس المهارة مع احترام أولوية SRS
  List<InterleavedReviewItem> interleave(List<InterleavedReviewItem> candidates) {
    if (candidates.length <= 2) return List.from(candidates);

    // ترتيب أولي تنازلي حسب أولوية FSRS-5
    final pool = List<InterleavedReviewItem>.from(candidates)
      ..sort((a, b) => b.overduePriority.compareTo(a.overduePriority));

    final interleavedQueue = <InterleavedReviewItem>[];
    LearningModality? lastModality;
    int currentConsecutiveCount = 0;

    while (pool.isNotEmpty) {
      int selectedIndex = -1;

      // البحث عن أعلى عنصر أولوية لا ينتهك الحد الأقصى للتتابع
      for (int i = 0; i < pool.length; i++) {
        final item = pool[i];
        if (item.modality != lastModality || currentConsecutiveCount < maxConsecutiveModality) {
          selectedIndex = i;
          break;
        }
      }

      // إذا تعذر العثور على نمط مختلف (بقاء عناصر من نفس النمط فقط)
      if (selectedIndex == -1) selectedIndex = 0;

      final selectedItem = pool.removeAt(selectedIndex);

      if (selectedItem.modality == lastModality) {
        currentConsecutiveCount++;
      } else {
        lastModality = selectedItem.modality;
        currentConsecutiveCount = 1;
      }

      interleavedQueue.add(selectedItem);
    }

    return interleavedQueue;
  }
}
