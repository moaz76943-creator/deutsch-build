import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/sentence_builder_notifier.dart';
import '../domain/sentence_builder_models.dart';

final class SentenceBuilderScreen extends StatefulWidget {
  const SentenceBuilderScreen({
    required this.notifier,
    this.level = 'A1',
    super.key,
  });

  final SentenceBuilderNotifier notifier;
  final String level;

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

final class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
  SentenceBuilderNotifier get notifier => widget.notifier;

  @override
  void initState() {
    super.initState();
    notifier.addListener(_refresh);
    if (notifier.activePuzzle == null) {
      unawaited(notifier.loadLevel(widget.level));
    }
  }

  @override
  void didUpdateWidget(covariant SentenceBuilderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != notifier) {
      oldWidget.notifier.removeListener(_refresh);
      notifier.addListener(_refresh);
    }
    if (oldWidget.level != widget.level) {
      unawaited(notifier.loadLevel(widget.level));
    }
  }

  @override
  void dispose() {
    notifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: Text('بناء الجملة', style: AppTypography.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: _Body(
            notifier: notifier,
            dark: dark,
          ),
        ),
      ),
    );
  }
}

final class _Body extends StatelessWidget {
  const _Body({
    required this.notifier,
    required this.dark,
  });

  final SentenceBuilderNotifier notifier;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final puzzle = notifier.activePuzzle;
    if (puzzle == null) {
      return Center(
        child: notifier.isBusy
            ? const CircularProgressIndicator()
            : Text(
                notifier.feedbackMessage.isEmpty
                    ? 'لا يوجد تمرين متاح.'
                    : notifier.feedbackMessage,
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        AppGlassCard(
          glowColor: AppColors.primary,
          borderColor:
              dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          backgroundColor:
              dark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'المعنى',
                style: AppTypography.label.copyWith(
                  color: dark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                puzzle.arabicTranslation,
                style: AppTypography.title.copyWith(
                  color: dark ? Colors.white : AppColors.darkSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _structureLabel(puzzle.structureType),
                style: AppTypography.label.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ArrangementCard(
          notifier: notifier,
          dark: dark,
        ),
        const SizedBox(height: 14),
        AppGlassCard(
          borderColor:
              dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          backgroundColor:
              dark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'بنك الكلمات',
                style: AppTypography.title.copyWith(
                  color: dark ? Colors.white : AppColors.darkSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: <Widget>[
                  for (final tile in notifier.availableTiles)
                    _WordTile(
                      tile: tile,
                      onTap: () => notifier.pickTile(tile),
                      dark: dark,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppGlassCard(
          onTap: notifier.isBusy
              ? null
              : () => unawaited(notifier.verifySentence()),
          glowColor: AppColors.mastery,
          borderColor: AppColors.mastery.withAlpha(80),
          backgroundColor:
              dark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Center(
            child: Text(
              'تحقق من الجملة',
              style: AppTypography.title.copyWith(color: AppColors.mastery),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: notifier.feedbackMessage.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  key: ValueKey<String>(notifier.feedbackMessage),
                  padding: const EdgeInsets.only(top: 14),
                  child: _FeedbackCard(
                    isCorrect: notifier.isCorrect,
                    message: notifier.feedbackMessage,
                    dark: dark,
                  ),
                ),
        ),
      ],
    );
  }

  static String _structureLabel(SentenceStructureType type) => switch (type) {
        SentenceStructureType.mainClause =>
          'جملة رئيسية · الفعل في الموقع 2',
        SentenceStructureType.subordinateWeil =>
          'جملة فرعية مع weil · الفعل في النهاية',
        SentenceStructureType.questionInversion =>
          'سؤال نعم/لا · الفعل قبل الفاعل',
      };
}

final class _ArrangementCard extends StatelessWidget {
  const _ArrangementCard({
    required this.notifier,
    required this.dark,
  });

  final SentenceBuilderNotifier notifier;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.achievement,
        borderColor: AppColors.achievement.withAlpha(78),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'الجملة التي تبنيها',
              style: AppTypography.title.copyWith(
                color: dark ? Colors.white : AppColors.darkSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (notifier.currentArrangement.isEmpty)
              Text(
                'اضغط على الكلمات بالترتيب الصحيح.',
                style: AppTypography.body.copyWith(
                  color: dark ? Colors.white70 : AppColors.darkSurface,
                ),
              )
            else
              Directionality(
                textDirection: TextDirection.ltr,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final tile in notifier.currentArrangement)
                      _WordTile(
                        tile: tile,
                        onTap: () => notifier.removeTile(tile),
                        dark: dark,
                        selected: true,
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
}

final class _WordTile extends StatelessWidget {
  const _WordTile({
    required this.tile,
    required this.onTap,
    required this.dark,
    this.selected = false,
  });

  final WordTileItem tile;
  final VoidCallback onTap;
  final bool dark;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppColors.achievement : AppColors.primary;
    return Semantics(
      button: true,
      label: selected
          ? 'إزالة ${tile.germanText} من الجملة'
          : 'إضافة ${tile.germanText} إلى الجملة',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: accent.withAlpha(dark ? 38 : 24),
            border: Border.all(color: accent.withAlpha(96)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            child: AppDirectionalText(
              tile.germanText,
              languageCode: 'de',
              style: AppTypography.body.copyWith(
                color: dark ? Colors.white : AppColors.darkSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.isCorrect,
    required this.message,
    required this.dark,
  });

  final bool? isCorrect;
  final String message;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final accent = isCorrect == true ? AppColors.mastery : AppColors.tertiary;
    return AppGlassCard(
      glowColor: accent,
      borderColor: accent.withAlpha(80),
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            isCorrect == true
                ? Icons.check_circle_rounded
                : Icons.lightbulb_outline_rounded,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body.copyWith(
                color: dark ? Colors.white : AppColors.darkSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
