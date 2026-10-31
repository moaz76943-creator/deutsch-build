import 'package:deutsch_bilarabi/core/content_contract.dart';

class LearningPathItem {
  final LearningContent item;
  final String mode;
  final String reason;
  final int priority;
  const LearningPathItem({
    required this.item,
    required this.mode,
    required this.reason,
    required this.priority,
  });
}

class LearningPath {
  final List<LearningPathItem> items;
  final String focusSkill;
  final int reviewCount;
  final int repairCount;
  final int newCount;
  final int listeningCount;
  final int productionCount;
  const LearningPath({
    required this.items,
    required this.focusSkill,
    required this.reviewCount,
    required this.repairCount,
    required this.newCount,
    required this.listeningCount,
    required this.productionCount,
  });
}
