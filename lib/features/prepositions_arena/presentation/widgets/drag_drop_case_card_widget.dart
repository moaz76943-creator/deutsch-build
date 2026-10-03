import 'package:flutter/material.dart';

import '../../../../core/localization/german_article_style.dart';
import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../domain/preposition_models.dart';

class DragDropCaseCardWidget extends StatelessWidget {
  const DragDropCaseCardWidget({
    required this.challenge,
    required this.onSelected,
    this.selectedAnswer,
    this.result,
    this.enabled = true,
    super.key,
  });

  final PrepositionChallenge challenge;
  final ValueChanged<String> onSelected;
  final String? selectedAnswer;
  final PrepositionAnswerResult? result;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(challenge.baseArticle);
    final isArticle =
        challenge.kind == PrepositionChallengeKind.articleChoice;

    return AppGlassCard(
      blur: 22,
      opacity: .14,
      borderColor: accent.withAlpha(92),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                isArticle
                    ? Icons.style_rounded
                    : Icons.swap_horiz_rounded,
                color: accent,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  isArticle
                      ? 'اختر الأداة المصروفة الصحيحة'
                      : 'اختر حرف الجر الصحيح',
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DragTarget<String>(
            onWillAcceptWithDetails: (_) => enabled,
            onAcceptWithDetails: (details) {
              if (enabled) onSelected(details.data);
            },
            builder: (context, candidates, rejected) {
              final active = candidates.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                constraints: const BoxConstraints(minHeight: 74),
                decoration: BoxDecoration(
                  color: accent.withAlpha(active ? 28 : 14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: accent.withAlpha(active ? 150 : 72),
                    width: active ? 1.8 : 1.1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  selectedAnswer?.isNotEmpty == true
                      ? selectedAnswer!
                      : 'اسحب الإجابة إلى هنا أو اضغط عليها',
                  textDirection: TextDirection.ltr,
                  style: AppTypography.title.copyWith(
                    color: selectedAnswer == null
                        ? null
                        : _resultColor(result, accent),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: challenge.options
                .map(
                  (option) => _DraggableOption(
                    option: option,
                    accent: accent,
                    enabled: enabled,
                    selected: selectedAnswer == option,
                    onTap: () {
                      if (enabled) onSelected(option);
                    },
                  ),
                )
                .toList(growable: false),
          ),
          if (result?.articleForm != null) ...<Widget>[
            const SizedBox(height: 16),
            _ArticleTransformation(
              form: result!.articleForm!,
              accent: accent,
            ),
          ],
        ],
      ),
    );
  }

  Color _accentFor(GermanArticle? article) => switch (article) {
        GermanArticle.der => AppColors.articleDer,
        GermanArticle.die => AppColors.articleDie,
        GermanArticle.das => AppColors.articleDas,
        null => AppColors.primary,
      };

  Color _resultColor(
    PrepositionAnswerResult? answer,
    Color accent,
  ) {
    if (answer == null) return accent;
    return answer.isCorrect ? AppColors.mastery : AppColors.articleDie;
  }
}

class _DraggableOption extends StatelessWidget {
  const _DraggableOption({
    required this.option,
    required this.accent,
    required this.enabled,
    required this.selected,
    required this.onTap,
  });

  final String option;
  final Color accent;
  final bool enabled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chip = _OptionChip(
      option: option,
      accent: accent,
      selected: selected,
    );
    return Draggable<String>(
      data: option,
      maxSimultaneousDrags: enabled ? 1 : 0,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 112, child: chip),
      ),
      childWhenDragging: Opacity(opacity: .35, child: chip),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: chip,
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.option,
    required this.accent,
    required this.selected,
  });

  final String option;
  final Color accent;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withAlpha(selected ? 34 : 18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withAlpha(selected ? 150 : 74),
        ),
        boxShadow: selected
            ? <BoxShadow>[
                BoxShadow(
                  color: accent.withAlpha(28),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Text(
          option,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(
            color: accent,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ArticleTransformation extends StatelessWidget {
  const _ArticleTransformation({
    required this.form,
    required this.accent,
  });

  final GermanArticleCaseForm form;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withAlpha(14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              form.baseArticle.name,
              textDirection: TextDirection.ltr,
              style: AppTypography.label.copyWith(color: accent),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 9),
              child: Icon(Icons.arrow_forward_rounded, size: 18),
            ),
            Text(
              form.surfaceArticle,
              textDirection: TextDirection.ltr,
              style: AppTypography.title.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
