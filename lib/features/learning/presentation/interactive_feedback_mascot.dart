import 'package:flutter/material.dart';

enum FeedbackTone {
  positive,
  guidance,
  neutral,
}

class InteractiveFeedbackMascot extends StatelessWidget {
  const InteractiveFeedbackMascot({
    super.key,
    required this.title,
    required this.explanation,
    required this.score,
    this.tone = FeedbackTone.neutral,
    this.onTap,
  });

  final String title;
  final String explanation;
  final double score;
  final FeedbackTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalizedScore = score.clamp(0.0, 1.0).toDouble();
    final percentage = (normalizedScore * 100).round().toString() + '%';
    final accent = switch (tone) {
      FeedbackTone.positive => scheme.primary,
      FeedbackTone.guidance => scheme.tertiary,
      FeedbackTone.neutral => scheme.secondary,
    };
    final icon = switch (tone) {
      FeedbackTone.positive => Icons.auto_awesome,
      FeedbackTone.guidance => Icons.lightbulb_outline,
      FeedbackTone.neutral => Icons.insights_outlined,
    };

    return Semantics(
      container: true,
      button: onTap != null,
      label: title + '. ' + percentage + '. ' + explanation,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                    border: Border.all(color: accent),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            percentage,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: normalizedScore,
                        color: accent,
                      ),
                      const SizedBox(height: 10),
                      Text(explanation),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
