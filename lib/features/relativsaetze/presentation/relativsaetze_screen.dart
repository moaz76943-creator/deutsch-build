import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/relativsaetze_notifier.dart';
import '../domain/relativsaetze_models.dart';

final class RelativsaetzeScreen extends StatefulWidget {
  const RelativsaetzeScreen({
    required this.notifier,
    super.key,
  });

  final RelativsaetzeNotifier notifier;

  @override
  State<RelativsaetzeScreen> createState() => _RelativsaetzeScreenState();
}

final class _RelativsaetzeScreenState extends State<RelativsaetzeScreen> {
  String? _selectedPronoun;

  RelativsaetzeNotifier get notifier => widget.notifier;

  @override
  void initState() {
    super.initState();
    notifier.addListener(_refresh);
    if (notifier.currentChallenge == null) {
      unawaited(notifier.nextChallenge());
    }
  }

  @override
  void didUpdateWidget(covariant RelativsaetzeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier == notifier) return;
    oldWidget.notifier.removeListener(_refresh);
    notifier.addListener(_refresh);
    _selectedPronoun = null;
  }

  @override
  void dispose() {
    notifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _filter(RelativeClauseFocus? focus) async {
    setState(() => _selectedPronoun = null);
    await notifier.filterByFocus(focus);
  }

  Future<void> _next() async {
    setState(() => _selectedPronoun = null);
    await notifier.nextChallenge();
  }

  Future<void> _submit() async {
    final selected = _selectedPronoun;
    if (selected == null) return;
    await notifier.submitAnswer(selected);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        dark ? AppColors.darkSurface : AppColors.lightSurface;
    final challenge = notifier.currentChallenge;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(
                  dark: dark,
                  surface: surface,
                ),
                const SizedBox(height: 12),
                _FocusFilter(
                  activeFocus: notifier.activeFocus,
                  enabled: !notifier.isBusy,
                  onSelected: (focus) => unawaited(_filter(focus)),
                ),
                const SizedBox(height: 14),
                if (challenge == null)
                  _EmptyCard(
                    surface: surface,
                    dark: dark,
                    isBusy: notifier.isBusy,
                    message: notifier.feedbackExplanation,
                    onRetry: () => unawaited(notifier.nextChallenge()),
                  )
                else ...<Widget>[
                  _GrammarPathCard(
                    challenge: challenge,
                    surface: surface,
                    dark: dark,
                  ),
                  const SizedBox(height: 12),
                  _PromptCard(
                    challenge: challenge,
                    surface: surface,
                    dark: dark,
                  ),
                  const SizedBox(height: 12),
                  _AnswerOptions(
                    options: notifier.options,
                    selected: _selectedPronoun,
                    enabled: !notifier.isBusy &&
                        notifier.isCorrect == null,
                    surface: surface,
                    dark: dark,
                    onSelected: (value) {
                      setState(() => _selectedPronoun = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _SubmitCard(
                    enabled: _selectedPronoun != null &&
                        !notifier.isBusy &&
                        notifier.isCorrect == null,
                    surface: surface,
                    onTap: () => unawaited(_submit()),
                  ),
                  if (notifier.isCorrect != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _FeedbackCard(
                      challenge: challenge,
                      correct: notifier.isCorrect!,
                      explanation:
                          notifier.feedbackExplanation ?? '',
                      surface: surface,
                    ),
                    const SizedBox(height: 12),
                    _NextCard(
                      surface: surface,
                      enabled: !notifier.isBusy,
                      onTap: () => unawaited(_next()),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.dark,
    required this.surface,
  });

  final bool dark;
  final Color surface;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor:
            dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        glowColor: AppColors.primary,
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.account_tree_rounded,
              color: AppColors.primary,
              size: 34,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ArabicText(
                    'محرك الجمل النسبية الألمانية',
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: 3),
                  _GermanText(
                    'Relativsätze · Präpositionen · dessen / deren',
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

final class _FocusFilter extends StatelessWidget {
  const _FocusFilter({
    required this.activeFocus,
    required this.enabled,
    required this.onSelected,
  });

  final RelativeClauseFocus? activeFocus;
  final bool enabled;
  final ValueChanged<RelativeClauseFocus?> onSelected;

  @override
  Widget build(BuildContext context) {
    const values = <RelativeClauseFocus?>[
      null,
      RelativeClauseFocus.prepositional,
      RelativeClauseFocus.genitivePossession,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final focus in values)
          AppGlassCard(
            onTap: enabled ? () => onSelected(focus) : null,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderColor: activeFocus == focus
                ? AppColors.secondary
                : AppColors.glassBorderDark,
            glowColor:
                activeFocus == focus ? AppColors.secondary : null,
            child: _ArabicText(
              focus?.arabicLabel ?? 'الكل',
              style: AppTypography.label.copyWith(
                color: activeFocus == focus
                    ? AppColors.secondary
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

final class _GrammarPathCard extends StatelessWidget {
  const _GrammarPathCard({
    required this.challenge,
    required this.surface,
    required this.dark,
  });

  final RelativeClauseChallengeItem challenge;
  final Color surface;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final preposition = challenge.preposition;
    final middle = preposition == null
        ? challenge.grammaticalCase.germanLabel
        : '$preposition + ${challenge.grammaticalCase.germanLabel}';

    return AppGlassCard(
      backgroundColor: surface,
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ArabicText(
            'مسار اختيار الضمير',
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              _GermanPill(
                text: challenge.antecedent,
                color: AppColors.primary,
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primary,
              ),
              _GermanPill(
                text: middle,
                color: AppColors.tertiary,
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.tertiary,
              ),
              _GermanPill(
                text: 'Relativpronomen',
                color: AppColors.secondary,
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.secondary,
              ),
              _GermanPill(
                text: 'Verb → Ende',
                color: AppColors.mastery,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.challenge,
    required this.surface,
    required this.dark,
  });

  final RelativeClauseChallengeItem challenge;
  final Color surface;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: AppColors.tertiary.withAlpha(88),
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ArabicText(
              challenge.focus.arabicLabel,
              style: AppTypography.label.copyWith(
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: 10),
            _GermanText(
              challenge.sourceSentence,
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            _GermanText(
              challenge.relativeIdea,
              style: AppTypography.body,
            ),
            const SizedBox(height: 12),
            _ArabicText(
              'اختر الضمير النسبي الذي يربط الفكرتين بشكل صحيح.',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _AnswerOptions extends StatelessWidget {
  const _AnswerOptions({
    required this.options,
    required this.selected,
    required this.enabled,
    required this.surface,
    required this.dark,
    required this.onSelected,
  });

  final List<String> options;
  final String? selected;
  final bool enabled;
  final Color surface;
  final bool dark;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          for (var index = 0; index < options.length; index += 1) ...<Widget>[
            AppGlassCard(
              onTap: enabled ? () => onSelected(options[index]) : null,
              backgroundColor: surface,
              borderColor: selected == options[index]
                  ? AppColors.primary
                  : (dark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight),
              glowColor:
                  selected == options[index] ? AppColors.primary : null,
              child: Row(
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  _OptionIndex(
                    index: index,
                    selected: selected == options[index],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GermanText(
                      options[index],
                      style: AppTypography.title.copyWith(
                        color: selected == options[index]
                            ? AppColors.primary
                            : null,
                      ),
                    ),
                  ),
                  Icon(
                    selected == options[index]
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selected == options[index]
                        ? AppColors.primary
                        : AppColors.glassBorderDark,
                  ),
                ],
              ),
            ),
            if (index != options.length - 1)
              const SizedBox(height: 8),
          ],
        ],
      );
}

final class _SubmitCard extends StatelessWidget {
  const _SubmitCard({
    required this.enabled,
    required this.surface,
    required this.onTap,
  });

  final bool enabled;
  final Color surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: enabled ? onTap : null,
        backgroundColor: surface,
        borderColor:
            enabled ? AppColors.mastery : AppColors.glassBorderDark,
        glowColor: enabled ? AppColors.mastery : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.fact_check_rounded,
              color:
                  enabled ? AppColors.mastery : AppColors.glassBorderDark,
            ),
            const SizedBox(width: 8),
            _ArabicText(
              'تحقق من الضمير',
              style: AppTypography.title.copyWith(
                color: enabled
                    ? AppColors.mastery
                    : AppColors.glassBorderDark,
              ),
            ),
          ],
        ),
      );
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.challenge,
    required this.correct,
    required this.explanation,
    required this.surface,
  });

  final RelativeClauseChallengeItem challenge;
  final bool correct;
  final String explanation;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    final accent =
        correct ? AppColors.mastery : AppColors.tertiary;
    return AppGlassCard(
      backgroundColor: surface,
      borderColor: accent,
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : Icons.lightbulb_rounded,
                color: accent,
              ),
              const SizedBox(width: 8),
              _ArabicText(
                correct ? 'إجابة صحيحة' : 'راجع القاعدة',
                style: AppTypography.title.copyWith(color: accent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _GermanText(
            challenge.correctSentence,
            style: AppTypography.title.copyWith(color: accent),
          ),
          const SizedBox(height: 10),
          _ArabicText(
            explanation,
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _NextCard extends StatelessWidget {
  const _NextCard({
    required this.surface,
    required this.enabled,
    required this.onTap,
  });

  final Color surface;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: enabled ? onTap : null,
        backgroundColor: surface,
        borderColor: AppColors.secondary,
        glowColor: AppColors.secondary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 8),
            _ArabicText(
              'التحدي التالي',
              style: AppTypography.title.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      );
}

final class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.surface,
    required this.dark,
    required this.isBusy,
    required this.message,
    required this.onRetry,
  });

  final Color surface;
  final bool dark;
  final bool isBusy;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: isBusy ? null : onRetry,
        backgroundColor: surface,
        borderColor:
            dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        child: Column(
          children: <Widget>[
            if (isBusy)
              const CircularProgressIndicator(
                color: AppColors.primary,
              )
            else
              const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            const SizedBox(height: 10),
            _ArabicText(
              isBusy
                  ? 'يتم تجهيز التحدي...'
                  : (message ?? 'لا توجد تحديات متاحة.'),
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

final class _GermanPill extends StatelessWidget {
  const _GermanPill({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withAlpha(20),
          border: Border.all(color: color.withAlpha(72)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          child: _GermanText(
            text,
            style: AppTypography.label.copyWith(color: color),
          ),
        ),
      );
}

final class _OptionIndex extends StatelessWidget {
  const _OptionIndex({
    required this.index,
    required this.selected,
  });

  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (selected
                  ? AppColors.primary
                  : AppColors.secondary)
              .withAlpha(22),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.secondary,
          ),
        ),
        child: Text(
          '${index + 1}',
          textDirection: TextDirection.ltr,
          style: AppTypography.label.copyWith(
            color:
                selected ? AppColors.primary : AppColors.secondary,
          ),
        ),
      );
}

final class _GermanText extends StatelessWidget {
  const _GermanText(
    this.text, {
    required this.style,
  }) : textAlign = null;

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          text,
          style: style,
          textAlign: textAlign,
        ),
      );
}

final class _ArabicText extends StatelessWidget {
  const _ArabicText(
    this.text, {
    required this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          text,
          style: style,
          textAlign: textAlign,
        ),
      );
}
