import 'package:flutter/material.dart';

import '../../../core/localization/german_article_style.dart';
import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/komposita_notifier.dart';
import '../domain/komposita_models.dart';

class KompositaBuilderScreen extends StatefulWidget {
  const KompositaBuilderScreen({
    required this.notifier,
    super.key,
  });

  final KompositaNotifier notifier;

  @override
  State<KompositaBuilderScreen> createState() =>
      _KompositaBuilderScreenState();
}

class _KompositaBuilderScreenState extends State<KompositaBuilderScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(widget.notifier.nextChallenge);
  }

  Future<void> _submit() async {
    final notifier = widget.notifier;
    final linking = notifier.selectedLinkingElement;
    final article = notifier.selectedArticle;
    if (linking == null || article == null || notifier.assembledParts.isEmpty) {
      return;
    }

    await notifier.checkComposition(
      notifier.assembledParts,
      linking,
      article,
    );
  }

  Future<void> _next() => widget.notifier.nextChallenge();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notifier,
      builder: (context, _) {
        final notifier = widget.notifier;
        final challenge = notifier.currentChallenge;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Komposita Builder',
              style: AppTypography.title,
            ),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _ModeSelector(
                    mode: notifier.mode,
                    onChanged: notifier.setMode,
                  ),
                  const SizedBox(height: 14),
                  if (notifier.isBusy && challenge == null)
                    const Center(child: CircularProgressIndicator())
                  else if (challenge == null)
                    AppGlassCard(
                      child: Text(
                        'لا توجد تحديات Komposita متاحة حاليًا.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body,
                      ),
                    )
                  else if (notifier.mode == KompositaMode.deconstruct)
                    _DeconstructView(challenge: challenge)
                  else
                    _AssembleView(
                      challenge: challenge,
                      notifier: notifier,
                      onSubmit: _submit,
                      onNext: _next,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.mode,
    required this.onChanged,
  });

  final KompositaMode mode;
  final ValueChanged<KompositaMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      blur: 18,
      opacity: .12,
      borderColor: AppColors.primary.withAlpha(68),
      child: SegmentedButton<KompositaMode>(
        segments: const <ButtonSegment<KompositaMode>>[
          ButtonSegment<KompositaMode>(
            value: KompositaMode.assemble,
            label: Text('تركيب'),
            icon: Icon(Icons.extension_rounded),
          ),
          ButtonSegment<KompositaMode>(
            value: KompositaMode.deconstruct,
            label: Text('تفكيك'),
            icon: Icon(Icons.account_tree_outlined),
          ),
        ],
        selected: <KompositaMode>{mode},
        onSelectionChanged: (selection) {
          if (selection.isNotEmpty) onChanged(selection.first);
        },
      ),
    );
  }
}

class _DeconstructView extends StatelessWidget {
  const _DeconstructView({required this.challenge});

  final KompositaChallengeItem challenge;

  @override
  Widget build(BuildContext context) {
    final accent = _articleColor(challenge.finalArticle);

    return Column(
      children: <Widget>[
        AppGlassCard(
          blur: 22,
          opacity: .14,
          borderColor: accent.withAlpha(86),
          glowColor: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'فكّك الكلمة المركبة',
                style: AppTypography.label.copyWith(color: accent),
              ),
              const SizedBox(height: 10),
              AppDirectionalText(
                challenge.displayWithArticle,
                languageCode: 'de',
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                challenge.overallMeaningAr,
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _PartsBreakdown(challenge: challenge),
        const SizedBox(height: 14),
        _ArticleRuleCard(
          challenge: challenge,
          selectedArticle: challenge.finalArticle,
          lastPartWord: challenge.parts.last.word,
          revealed: true,
        ),
        const SizedBox(height: 14),
        AppGlassCard(
          borderColor: AppColors.secondary.withAlpha(70),
          child: Text(
            challenge.derivationExplanationAr,
            style: AppTypography.body,
          ),
        ),
      ],
    );
  }
}

class _PartsBreakdown extends StatelessWidget {
  const _PartsBreakdown({required this.challenge});

  final KompositaChallengeItem challenge;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (var index = 0; index < challenge.parts.length; index++) {
      final part = challenge.parts[index];
      children.add(
        Expanded(
          child: _PartDetailCard(
            part: part,
            label: index == challenge.parts.length - 1
                ? 'Grundwort'
                : 'Bestimmungswort',
          ),
        ),
      );

      if (index < challenge.parts.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.add_rounded,
                  color: AppColors.secondary,
                ),
                Text(
                  challenge.linkingElement == LinkingElement.none
                      ? '—'
                      : '+${challenge.linkingElement.surface}',
                  textDirection: TextDirection.ltr,
                  style: AppTypography.label.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return AppGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class _PartDetailCard extends StatelessWidget {
  const _PartDetailCard({
    required this.part,
    required this.label,
  });

  final CompoundWordPart part;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = _articleColor(part.originalArticle);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: AppTypography.label,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              part.originalArticle.name,
              textDirection: TextDirection.ltr,
              style: AppTypography.label.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
            AppDirectionalText(
              part.word,
              languageCode: 'de',
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              part.arabicMeaning,
              textAlign: TextAlign.center,
              style: AppTypography.label,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssembleView extends StatelessWidget {
  const _AssembleView({
    required this.challenge,
    required this.notifier,
    required this.onSubmit,
    required this.onNext,
  });

  final KompositaChallengeItem challenge;
  final KompositaNotifier notifier;
  final Future<void> Function() onSubmit;
  final Future<void> Function() onNext;

  @override
  Widget build(BuildContext context) {
    final availableParts = challenge.parts
        .where((part) {
          final requiredCount = challenge.parts
              .where((candidate) => candidate.word == part.word)
              .length;
          final usedCount = notifier.assembledParts
              .where((word) => word == part.word)
              .length;
          return usedCount < requiredCount;
        })
        .toList(growable: false);

    return Column(
      children: <Widget>[
        AppGlassCard(
          borderColor: AppColors.secondary.withAlpha(78),
          glowColor: AppColors.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'ركّب الكلمة المناسبة للمعنى:',
                style: AppTypography.label,
              ),
              const SizedBox(height: 8),
              Text(
                challenge.overallMeaningAr,
                textAlign: TextAlign.center,
                style: AppTypography.title,
              ),
              const SizedBox(height: 5),
              Text(
                'المستوى: ${challenge.level}',
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _PuzzleSource(
          parts: availableParts,
          enabled: !notifier.showExplanation,
          onSelected: notifier.choosePart,
        ),
        const SizedBox(height: 14),
        _AssemblyTarget(
          parts: notifier.assembledParts,
          enabled: !notifier.showExplanation,
          onAccepted: notifier.choosePart,
          onUndo: notifier.removeLastPart,
          onClear: notifier.clearAssembly,
        ),
        const SizedBox(height: 14),
        _LinkingElementSelector(
          selected: notifier.selectedLinkingElement,
          enabled: !notifier.showExplanation,
          onSelected: notifier.selectLinkingElement,
        ),
        const SizedBox(height: 14),
        _ArticleSelector(
          selected: notifier.selectedArticle,
          enabled: !notifier.showExplanation,
          onSelected: notifier.selectArticle,
        ),
        const SizedBox(height: 14),
        _ArticleRuleCard(
          challenge: challenge,
          selectedArticle: notifier.selectedArticle,
          lastPartWord: notifier.assembledParts.isEmpty
              ? null
              : notifier.assembledParts.last,
          revealed: notifier.showExplanation,
        ),
        const SizedBox(height: 14),
        if (!notifier.showExplanation)
          FilledButton.icon(
            onPressed: notifier.isBusy ||
                    notifier.assembledParts.length != challenge.parts.length ||
                    notifier.selectedArticle == null ||
                    notifier.selectedLinkingElement == null
                ? null
                : onSubmit,
            icon: const Icon(Icons.check_rounded),
            label: const Text('تحقق من التركيب'),
          )
        else ...<Widget>[
          _ResultCard(
            challenge: challenge,
            isCorrect: notifier.isCorrect == true,
            explanationAr: notifier.explanationAr,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: notifier.isBusy ? null : onNext,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('الكلمة التالية'),
          ),
        ],
      ],
    );
  }
}

class _PuzzleSource extends StatelessWidget {
  const _PuzzleSource({
    required this.parts,
    required this.enabled,
    required this.onSelected,
  });

  final List<CompoundWordPart> parts;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('قطع البازل', style: AppTypography.title),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: parts
                .map(
                  (part) => _DraggablePart(
                    part: part,
                    enabled: enabled,
                    onTap: () => onSelected(part.word),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _DraggablePart extends StatelessWidget {
  const _DraggablePart({
    required this.part,
    required this.enabled,
    required this.onTap,
  });

  final CompoundWordPart part;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _articleColor(part.originalArticle);
    final piece = _PuzzlePiece(part: part, color: color);

    return Draggable<String>(
      data: part.word,
      maxSimultaneousDrags: enabled ? 1 : 0,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 130, child: piece),
      ),
      childWhenDragging: Opacity(opacity: .32, child: piece),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: piece,
      ),
    );
  }
}

class _PuzzlePiece extends StatelessWidget {
  const _PuzzlePiece({
    required this.part,
    required this.color,
  });

  final CompoundWordPart part;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(88)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withAlpha(22),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              part.originalArticle.name,
              textDirection: TextDirection.ltr,
              style: AppTypography.label.copyWith(color: color),
            ),
            AppDirectionalText(
              part.word,
              languageCode: 'de',
              style: AppTypography.title.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssemblyTarget extends StatelessWidget {
  const _AssemblyTarget({
    required this.parts,
    required this.enabled,
    required this.onAccepted,
    required this.onUndo,
    required this.onClear,
  });

  final List<String> parts;
  final bool enabled;
  final ValueChanged<String> onAccepted;
  final VoidCallback onUndo;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => enabled,
      onAcceptWithDetails: (details) => onAccepted(details.data),
      builder: (context, candidates, rejected) {
        final active = candidates.isNotEmpty;
        return AppGlassCard(
          blur: 20,
          opacity: active ? .18 : .12,
          borderColor: AppColors.primary.withAlpha(active ? 140 : 72),
          glowColor: active ? AppColors.primary : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'منطقة التركيب',
                      style: AppTypography.title,
                    ),
                  ),
                  IconButton(
                    onPressed: enabled && parts.isNotEmpty ? onUndo : null,
                    tooltip: 'تراجع',
                    icon: const Icon(Icons.undo_rounded),
                  ),
                  IconButton(
                    onPressed: enabled && parts.isNotEmpty ? onClear : null,
                    tooltip: 'مسح',
                    icon: const Icon(Icons.clear_all_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (parts.isEmpty)
                Text(
                  'اسحب القطع إلى هنا أو اضغط عليها بالترتيب.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body,
                )
              else
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 7,
                  runSpacing: 7,
                  children: parts
                      .map(
                        (part) => DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(72),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              part,
                              textDirection: TextDirection.ltr,
                              style: AppTypography.title.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LinkingElementSelector extends StatelessWidget {
  const _LinkingElementSelector({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final LinkingElement? selected;
  final bool enabled;
  final ValueChanged<LinkingElement> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Fugenlaut / حرف الوصل', style: AppTypography.title),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LinkingElement.values
                .map(
                  (element) => ChoiceChip(
                    label: Text(
                      element == LinkingElement.none
                          ? 'بدون'
                          : '+${element.surface}',
                      textDirection: TextDirection.ltr,
                    ),
                    selected: selected == element,
                    onSelected: enabled
                        ? (_) => onSelected(element)
                        : null,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _ArticleSelector extends StatelessWidget {
  const _ArticleSelector({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final GermanArticle? selected;
  final bool enabled;
  final ValueChanged<GermanArticle> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('اختر أداة الكلمة الناتجة', style: AppTypography.title),
          const SizedBox(height: 10),
          Row(
            children: GermanArticle.values
                .map(
                  (article) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _ArticleButton(
                        article: article,
                        selected: selected == article,
                        enabled: enabled,
                        onTap: () => onSelected(article),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _ArticleButton extends StatelessWidget {
  const _ArticleButton({
    required this.article,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final GermanArticle article;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _articleColor(article);
    return AppGlassCard(
      onTap: enabled ? onTap : null,
      blur: 12,
      opacity: selected ? .2 : .08,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      borderRadius: 20,
      borderColor: color.withAlpha(selected ? 150 : 62),
      glowColor: selected ? color : null,
      child: Text(
        article.name,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        style: AppTypography.title.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ArticleRuleCard extends StatelessWidget {
  const _ArticleRuleCard({
    required this.challenge,
    required this.selectedArticle,
    required this.lastPartWord,
    required this.revealed,
  });

  final KompositaChallengeItem challenge;
  final GermanArticle? selectedArticle;
  final String? lastPartWord;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final displayedArticle =
        revealed ? challenge.finalArticle : selectedArticle;
    final color = displayedArticle == null
        ? AppColors.secondary
        : _articleColor(displayedArticle);

    return AppGlassCard(
      borderColor: color.withAlpha(84),
      glowColor: revealed ? color : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.arrow_downward_rounded, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الأداة تتبع العنصر الأخير',
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                lastPartWord ?? 'Grundwort',
                textDirection: TextDirection.ltr,
                style: AppTypography.title,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_forward_rounded),
              ),
              Text(
                displayedArticle?.name ?? '?',
                textDirection: TextDirection.ltr,
                style: AppTypography.display.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.articleRuleAr,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.challenge,
    required this.isCorrect,
    required this.explanationAr,
  });

  final KompositaChallengeItem challenge;
  final bool isCorrect;
  final String explanationAr;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.mastery : AppColors.articleDie;
    return AppGlassCard(
      borderColor: color.withAlpha(92),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                isCorrect
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCorrect
                      ? 'تركيب صحيح'
                      : 'التركيب الصحيح: ${challenge.displayWithArticle}',
                  style: AppTypography.title.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(explanationAr, style: AppTypography.body),
        ],
      ),
    );
  }
}

Color _articleColor(GermanArticle article) => switch (article) {
      GermanArticle.der => AppColors.articleDer,
      GermanArticle.die => AppColors.articleDie,
      GermanArticle.das => AppColors.articleDas,
    };
