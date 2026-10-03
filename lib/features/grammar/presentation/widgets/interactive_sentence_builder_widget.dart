import 'package:flutter/material.dart';

import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../domain/grammar_drill_models.dart';

class InteractiveSentenceBuilderWidget extends StatelessWidget {
  const InteractiveSentenceBuilderWidget({
    required this.exercise,
    required this.orderedTokenIds,
    required this.onAddToken,
    required this.onRemoveToken,
    this.enabled = true,
    super.key,
  });

  final SentenceReorderExercise exercise;
  final List<String> orderedTokenIds;
  final ValueChanged<String> onAddToken;
  final ValueChanged<String> onRemoveToken;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final byId = <String, GrammarToken>{
      for (final token in exercise.tokens) token.id: token,
    };
    final selected = orderedTokenIds
        .map((id) => byId[id])
        .whereType<GrammarToken>()
        .toList(growable: false);
    final available = exercise.tokens
        .where((token) => !orderedTokenIds.contains(token.id))
        .toList(growable: false);

    return AppGlassCard(
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            exercise.instructionAr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            exercise.translationAr,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          DragTarget<String>(
            onWillAcceptWithDetails: (_) => enabled,
            onAcceptWithDetails: (details) => onAddToken(details.data),
            builder: (context, candidates, rejected) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              constraints: const BoxConstraints(minHeight: 82),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: candidates.isNotEmpty
                    ? AppColors.primary.withAlpha(22)
                    : Theme.of(context).colorScheme.surface.withAlpha(80),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: candidates.isNotEmpty
                      ? AppColors.primary
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selected.isEmpty
                    ? <Widget>[
                        Text(
                          'اسحب الكلمات إلى هنا أو اضغط عليها بالترتيب.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ]
                    : <Widget>[
                        for (final token in selected)
                          _TokenChip(
                            token: token,
                            selected: true,
                            enabled: enabled,
                            onTap: () => onRemoveToken(token.id),
                          ),
                      ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final token in available)
                Draggable<String>(
                  data: token.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _TokenChip(
                      token: token,
                      selected: false,
                      enabled: enabled,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: .35,
                    child: _TokenChip(
                      token: token,
                      selected: false,
                      enabled: false,
                    ),
                  ),
                  child: _TokenChip(
                    token: token,
                    selected: false,
                    enabled: enabled,
                    onTap: enabled ? () => onAddToken(token.id) : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TokenChip extends StatelessWidget {
  const _TokenChip({
    required this.token,
    required this.selected,
    required this.enabled,
    this.onTap,
  });

  final GrammarToken token;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(token);
    return ActionChip(
      onPressed: enabled ? onTap : null,
      avatar: selected
          ? Icon(Icons.check_rounded, size: 16, color: accent)
          : null,
      label: Text(
        token.text,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          color: enabled ? accent : accent.withAlpha(110),
          fontWeight: FontWeight.w800,
        ),
      ),
      side: BorderSide(color: accent.withAlpha(120)),
      backgroundColor: accent.withAlpha(selected ? 28 : 16),
    );
  }

  Color _accentFor(GrammarToken token) {
    final normalized = token.text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zäöüß]'), '');
    if (normalized == 'der') return AppColors.articleDer;
    if (normalized == 'die') return AppColors.articleDie;
    if (normalized == 'das') return AppColors.articleDas;

    return switch (token.role) {
      GrammarTokenRole.verb => AppColors.primary,
      GrammarTokenRole.connector => AppColors.achievement,
      GrammarTokenRole.accusativeMarker => AppColors.tertiary,
      GrammarTokenRole.dativeMarker => AppColors.secondary,
      GrammarTokenRole.articleMasculine => AppColors.articleDer,
      GrammarTokenRole.articleFeminine => AppColors.articleDie,
      GrammarTokenRole.articleNeuter => AppColors.articleDas,
      GrammarTokenRole.subject || GrammarTokenRole.other =>
        AppColors.articleOther,
    };
  }
}
