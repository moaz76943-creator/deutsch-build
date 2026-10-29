import 'package:flutter/material.dart';

import '../../../../design_system/app_audio_button.dart';
import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';
import '../../application/sentence_token_bank.dart';
import '../../domain/grammar_drill_models.dart';

class InteractiveSentenceBuilderWidget extends StatefulWidget {
  const InteractiveSentenceBuilderWidget({
    required this.exercise,
    required this.orderedTokenIds,
    required this.onAddToken,
    required this.onRemoveToken,
    required this.targetLanguageCode,
    this.onSpeakSentence,
    this.enabled = true,
    super.key,
  });

  final SentenceReorderExercise exercise;
  final List<String> orderedTokenIds;
  final ValueChanged<String> onAddToken;
  final ValueChanged<String> onRemoveToken;
  final String targetLanguageCode;
  final VoidCallback? onSpeakSentence;
  final bool enabled;

  @override
  State<InteractiveSentenceBuilderWidget> createState() =>
      _InteractiveSentenceBuilderWidgetState();
}

class _InteractiveSentenceBuilderWidgetState
    extends State<InteractiveSentenceBuilderWidget> {
  late List<GrammarToken> _tokenBank;

  @override
  void initState() {
    super.initState();
    _tokenBank = SentenceTokenBank.shuffled(widget.exercise);
  }

  @override
  void didUpdateWidget(
    covariant InteractiveSentenceBuilderWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      _tokenBank = SentenceTokenBank.shuffled(widget.exercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    final byId = <String, GrammarToken>{
      for (final token in widget.exercise.tokens) token.id: token,
    };
    final selected = widget.orderedTokenIds
        .map((id) => byId[id])
        .whereType<GrammarToken>()
        .toList(growable: false);
    final available = _tokenBank
        .where((token) => !widget.orderedTokenIds.contains(token.id))
        .toList(growable: false);

    return AppGlassCard(
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      widget.exercise.instructionAr,
                      languageCode: 'ar',
                      style: AppTypography.title.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 8),
                    AppDirectionalText(
                      widget.exercise.translationAr,
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
              if (widget.onSpeakSentence != null) ...<Widget>[
                const SizedBox(width: 10),
                AppAudioButton(
                  onPressed: widget.onSpeakSentence,
                  semanticLabel: 'استمع إلى الجملة الصحيحة',
                  activeColor: AppColors.primary,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          DragTarget<String>(
            onWillAcceptWithDetails: (_) => widget.enabled,
            onAcceptWithDetails: (details) =>
                widget.onAddToken(details.data),
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
                        AppDirectionalText(
                          'اسحب الكلمات إلى هنا أو اضغط عليها بالترتيب.',
                          languageCode: 'ar',
                          style: AppTypography.label,
                        ),
                      ]
                    : <Widget>[
                        for (final token in selected)
                          _TokenChip(
                            token: token,
                            selected: true,
                            enabled: widget.enabled,
                            languageCode: widget.targetLanguageCode,
                            onTap: () => widget.onRemoveToken(token.id),
                          ),
                      ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final token in available)
                Draggable<String>(
                  data: token.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _TokenChip(
                      token: token,
                      selected: false,
                      enabled: widget.enabled,
                      languageCode: widget.targetLanguageCode,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: .35,
                    child: _TokenChip(
                      token: token,
                      selected: false,
                      enabled: false,
                      languageCode: widget.targetLanguageCode,
                    ),
                  ),
                  child: _TokenChip(
                    token: token,
                    selected: false,
                    enabled: widget.enabled,
                    languageCode: widget.targetLanguageCode,
                    onTap: widget.enabled
                        ? () => widget.onAddToken(token.id)
                        : null,
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
    required this.languageCode,
    this.onTap,
  });

  final GrammarToken token;
  final bool selected;
  final bool enabled;
  final String languageCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(token);
    return ActionChip(
      onPressed: enabled ? onTap : null,
      avatar: selected
          ? Icon(Icons.check_rounded, size: 16, color: accent)
          : null,
      label: AppDirectionalText(
        token.text,
        languageCode: languageCode,
        style: AppTypography.label.copyWith(
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
