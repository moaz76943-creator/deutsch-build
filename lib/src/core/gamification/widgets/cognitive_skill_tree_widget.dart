import 'package:flutter/material.dart';

/// Operational unlock state of a node in the skill tree.
enum SkillNodeState { locked, inProgress, mastered }

/// Represents an individual skill checkpoint in the non-linear learning tree.
class CognitiveSkillNode {
  final String id;
  final String title;
  final String iconCode;
  final double bktMastery; // 0.0 to 1.0
  final List<String> prerequisiteIds;

  const CognitiveSkillNode({
    required this.id,
    required this.title,
    required this.iconCode,
    required this.bktMastery,
    this.prerequisiteIds = const [],
  });

  SkillNodeState get state {
    if (bktMastery >= 0.85) return SkillNodeState.mastered;
    if (bktMastery >= 0.20) return SkillNodeState.inProgress;
    return SkillNodeState.locked;
  }
}

/// Interactive RPG-style non-linear skill tree visualization.
class CognitiveSkillTreeWidget extends StatelessWidget {
  final List<CognitiveSkillNode> nodes;
  final void Function(CognitiveSkillNode node)? onNodeSelected;

  const CognitiveSkillTreeWidget({
    super.key,
    required this.nodes,
    this.onNodeSelected,
  });

  Color _getNodeColor(SkillNodeState state, ThemeData theme) {
    switch (state) {
      case SkillNodeState.mastered:
        return Colors.amber.shade700; // Gold star tier
      case SkillNodeState.inProgress:
        return theme.colorScheme.primary; // Active learning
      case SkillNodeState.locked:
        return Colors.grey.shade400; // Locked prerequisite
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        itemCount: nodes.length,
        separatorBuilder: (_, __) => Center(
          child: Container(
            width: 3.0,
            height: 24.0,
            color: theme.dividerColor.withOpacity(0.3),
          ),
        ),
        itemBuilder: (context, index) {
          final node = nodes[index];
          final color = _getNodeColor(node.state, theme);

          return Center(
            child: InkWell(
              onTap: node.state != SkillNodeState.locked && onNodeSelected != null
                  ? () => onNodeSelected!(node)
                  : null,
              borderRadius: BorderRadius.circular(32.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(32.0),
                  border: Border.all(color: color, width: 2.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      node.state == SkillNodeState.mastered
                          ? Icons.stars_rounded
                          : (node.state == SkillNodeState.inProgress ? Icons.play_circle_filled_rounded : Icons.lock_outline_rounded),
                      color: color,
                      size: 26.0,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      node.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '${(node.bktMastery * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
