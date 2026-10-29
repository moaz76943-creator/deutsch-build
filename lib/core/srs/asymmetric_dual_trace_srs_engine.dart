import 'dart:math' as math;

enum ReviewDirection {
  passiveRecognition, // L2 -> L1 (German -> Native): سهلة واستدعاء غير مقيد
  activeProduction,    // L1 -> L2 (Native -> German): صعبة وتتطلب استدعاءً صوتياً صرفياً كاملاً
}

class DualTraceMemoryState {
  final double passiveStability; // استقرار مسار الفهم والتعرف
  final double activeStability;  // استقرار مسار الإنتاج والتحدث
  final double passiveDifficulty;
  final double activeDifficulty;

  const DualTraceMemoryState({
    required this.passiveStability,
    required this.activeStability,
    required this.passiveDifficulty,
    required this.activeDifficulty,
  });

  factory DualTraceMemoryState.initial() => const DualTraceMemoryState(
        passiveStability: 0.0,
        activeStability: 0.0,
        passiveDifficulty: 4.0, // الصعوبة الفطرية للتعرف أقل
        activeDifficulty: 6.5,  // الصعوبة الفطرية للإنتاج أعلى حتماً
      );
}

/// Offline cognitive engine modeling bidirectional retrieval asymmetry and cross-directional stability coupling.
/// Law of Directed Pairs: A -> B != B -> A.
class AsymmetricDualTraceSrsEngine {
  /// تحديث حالة الذاكرة بناءً على اتجاه المراجعة مع تطبيق الاقتران اللامتناظر
  DualTraceMemoryState recordReview({
    required DualTraceMemoryState current,
    required ReviewDirection direction,
    required bool success,
  }) {
    double newPassiveStab = current.passiveStability;
    double newActiveStab = current.activeStability;

    if (direction == ReviewDirection.activeProduction) {
      if (success) {
        // الإنتاج الناجح يرفع استقرار الإنتاج كاملاً (+100%)، ويعزز التعرف السلبي تلقائياً (+50%)
        newActiveStab = current.activeStability == 0.0 ? 1.0 : current.activeStability * 2.1;
        newPassiveStab = current.passiveStability == 0.0 ? 1.5 : current.passiveStability * 1.5;
      } else {
        // الفشل في الإنتاج يخفض استقرار الإنتاج ولا يدمر مسار التعرف كلياً
        newActiveStab = math.max(0.2, current.activeStability * 0.4);
      }
    } else {
      // الاتجاه السلبي: التعرف (L2 -> L1)
      if (success) {
        // التعرف الناجح يرفع استقرار التعرف كاملاً، لكنه لا يقدم للإنتاج النشط سوى تعزيز جزئي ضئيل (+15%)
        newPassiveStab = current.passiveStability == 0.0 ? 1.2 : current.passiveStability * 2.0;
        newActiveStab = current.activeStability * 1.15;
      } else {
        newPassiveStab = math.max(0.2, current.passiveStability * 0.4);
        newActiveStab = math.max(0.1, current.activeStability * 0.3);
      }
    }

    return DualTraceMemoryState(
      passiveStability: double.parse(newPassiveStab.toStringAsFixed(2)),
      activeStability: double.parse(newActiveStab.toStringAsFixed(2)),
      passiveDifficulty: current.passiveDifficulty,
      activeDifficulty: current.activeDifficulty,
    );
  }

  /// ترشيح الاتجاه الأجدر بالمراجعة حالياً لمنع وهم الطلاقة
  ReviewDirection suggestNextDirection(DualTraceMemoryState state) {
    // إذا كان مسار الإنتاج النشط متأخراً أو غير مثبت، نعطيه الأولوية
    if (state.activeStability <= state.passiveStability * 0.6) {
      return ReviewDirection.activeProduction;
    }
    return ReviewDirection.passiveRecognition;
  }
}
