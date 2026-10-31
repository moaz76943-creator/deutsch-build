import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/konjunktiv_notifier.dart';
import '../domain/konjunktiv_models.dart';

final class KonjunktivScreen extends StatefulWidget {
  const KonjunktivScreen({
    required this.notifier,
    super.key,
  });

  final KonjunktivNotifier notifier;

  @override
  State<KonjunktivScreen> createState() => _KonjunktivScreenState();
}

final class _KonjunktivScreenState extends State<KonjunktivScreen> {
  String? _selectedOption;

  KonjunktivNotifier get notifier => widget.notifier;

  @override
  void initState() {
    super.initState();
    notifier.addListener(_refresh);
    if (notifier.currentChallenge == null) {
      unawaited(notifier.nextChallenge());
    }
  }

  @override
  void didUpdateWidget(covariant KonjunktivScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier == notifier) return;
    oldWidget.notifier.removeListener(_refresh);
    notifier.addListener(_refresh);
  }

  @override
  void dispose() {
    notifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _selectUsage(KonjunktivUsage? usage) async {
    setState(() => _selectedOption = null);
    await notifier.filterByUsage(usage);
  }

  Future<void> _next() async {
    setState(() => _selectedOption = null);
    await notifier.nextChallenge();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final challenge = notifier.currentChallenge;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: Text('ساحة Konjunktiv II', style: AppTypography.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: challenge == null
              ? _EmptyState(
                  isBusy: notifier.isBusy,
                  message: notifier.feedbackExplanation,
                  onRetry: () => unawaited(notifier.nextChallenge()),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  children: <Widget>[
                    _UsageFilter(
                      activeUsage: notifier.activeUsage,
                      enabled: !notifier.isBusy,
                      onSelected: (usage) =>
                          unawaited(_selectUsage(usage)),
                    ),
                    const SizedBox(height: 12),
                    _ToneIndicator(
                      usage: challenge.usage,
                      dark: dark,
                    ),
                    const SizedBox(height: 12),
                    _RealityCard(
                      challenge: challenge,
                      dark: dark,
                    ),
                    const SizedBox(height: 14),
                    _PromptCard(
                      challenge: challenge,
                      dark: dark,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'اختر الصيغة الأنسب',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'هل تحتاج صيغة أصلية مثل wäre / hätte / könnte، أم würde + Infinitiv؟',
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: 9),
                    _AnswerOptions(
                      options: notifier.options,
                      selected: _selectedOption,
                      enabled: !notifier.isBusy &&
                          notifier.isCorrect == null,
                      onSelected: (value) {
                        setState(() => _selectedOption = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    _CheckButton(
                      enabled: _selectedOption != null &&
                          !notifier.isBusy &&
                          notifier.isCorrect == null,
                      onTap: () => unawaited(
                        notifier.checkKonjunktivAnswer(
                          _selectedOption!,
                        ),
                      ),
                    ),
                    if (notifier.isCorrect != null) ...<Widget>[
                      const SizedBox(height: 14),
                      _FeedbackCard(
                        challenge: challenge,
                        isCorrect: notifier.isCorrect!,
                        explanation:
                            notifier.feedbackExplanation ?? '',
                        dark: dark,
                      ),
                      const SizedBox(height: 12),
                      AppGlassCard(
                        onTap: notifier.isBusy
                            ? null
                            : () => unawaited(_next()),
                        borderColor: AppColors.primary.withAlpha(92),
                        glowColor: AppColors.primary,
                        backgroundColor: dark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'التحدي التالي',
                              style: AppTypography.title.copyWith(
                                color: dark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

final class _UsageFilter extends StatelessWidget {
  const _UsageFilter({
    required this.activeUsage,
    required this.enabled,
    required this.onSelected,
  });

  final KonjunktivUsage? activeUsage;
  final bool enabled;
  final ValueChanged<KonjunktivUsage?> onSelected;

  @override
  Widget build(BuildContext context) {
    const usages = <KonjunktivUsage?>[
      null,
      KonjunktivUsage.politeRequest,
      KonjunktivUsage.unrealWish,
      KonjunktivUsage.hypotheticalCondition,
      KonjunktivUsage.advice,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: <Widget>[
          for (final usage in usages) ...<Widget>[
            _FilterChipCard(
              label: usage?.arabicLabel ?? 'الكل',
              selected: activeUsage == usage,
              enabled: enabled,
              onTap: () => onSelected(usage),
            ),
            if (usage != usages.last) const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}

final class _FilterChipCard extends StatelessWidget {
  const _FilterChipCard({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: enabled ? onTap : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderColor: selected
            ? AppColors.primary
            : AppColors.primary.withAlpha(42),
        glowColor: selected ? AppColors.primary : null,
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: selected ? AppColors.primary : null,
          ),
        ),
      );
}

final class _ToneIndicator extends StatelessWidget {
  const _ToneIndicator({
    required this.usage,
    required this.dark,
  });

  final KonjunktivUsage usage;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final (targetLabel, accent, icon) = switch (usage) {
      KonjunktivUsage.politeRequest => (
          'مؤدبة',
          AppColors.secondary,
          Icons.room_service_rounded,
        ),
      KonjunktivUsage.unrealWish => (
          'تمنٍ',
          AppColors.achievement,
          Icons.auto_awesome_rounded,
        ),
      KonjunktivUsage.hypotheticalCondition => (
          'افتراضية',
          AppColors.tertiary,
          Icons.alt_route_rounded,
        ),
      KonjunktivUsage.advice => (
          'نصيحة لطيفة',
          AppColors.mastery,
          Icons.tips_and_updates_rounded,
        ),
    };

    return AppGlassCard(
      borderColor: accent.withAlpha(82),
      glowColor: accent,
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: accent),
              const SizedBox(width: 8),
              Text(
                'مؤشر النبرة',
                style: AppTypography.title.copyWith(color: accent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _ToneNode(
                  label: 'Indikativ',
                  detail: 'عادية / مباشرة',
                  active: false,
                  color: AppColors.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: accent,
                ),
              ),
              Expanded(
                child: _ToneNode(
                  label: 'Konjunktiv II',
                  detail: targetLabel,
                  active: true,
                  color: accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _ToneNode extends StatelessWidget {
  const _ToneNode({
    required this.label,
    required this.detail,
    required this.active,
    required this.color,
  });

  final String label;
  final String detail;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withAlpha(active ? 32 : 14),
          border: Border.all(
            color: color.withAlpha(active ? 110 : 42),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Column(
            children: <Widget>[
              Text(
                label,
                textDirection: TextDirection.ltr,
                style: AppTypography.label.copyWith(color: color),
              ),
              const SizedBox(height: 2),
              Text(detail, style: AppTypography.label),
            ],
          ),
        ),
      );
}

final class _RealityCard extends StatelessWidget {
  const _RealityCard({
    required this.challenge,
    required this.dark,
  });

  final KonjunktivChallengeItem challenge;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        borderColor:
            dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'الواقع — Indikativ',
              style: AppTypography.label.copyWith(
                color: dark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              challenge.indicativeSentence,
              languageCode: 'de',
              style: AppTypography.title,
            ),
          ],
        ),
      );
}

final class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.challenge,
    required this.dark,
  });

  final KonjunktivChallengeItem challenge;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      glowColor: AppColors.tertiary,
      borderColor: AppColors.tertiary.withAlpha(76),
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              _MiniTag(
                text: challenge.usage.arabicLabel,
                color: AppColors.tertiary,
              ),
              _MiniTag(
                text: 'الفعل: ${challenge.targetVerb}',
                color: AppColors.secondary,
              ),
              _MiniTag(
                text: 'الضمير: ${challenge.personalPronoun}',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'حوّل المعنى إلى Konjunktiv II بالنبرة المطلوبة، ثم اختر التصريف أو البناء المناسب.',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}

final class _MiniTag extends StatelessWidget {
  const _MiniTag({
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
          border: Border.all(color: color.withAlpha(64)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Text(
            text,
            style: AppTypography.label.copyWith(color: color),
          ),
        ),
      );
}

final class _AnswerOptions extends StatelessWidget {
  const _AnswerOptions({
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final List<String> options;
  final String? selected;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          for (var index = 0; index < options.length; index += 1) ...<Widget>[
            AppGlassCard(
              onTap: enabled ? () => onSelected(options[index]) : null,
              borderColor: selected == options[index]
                  ? AppColors.primary
                  : AppColors.primary.withAlpha(44),
              glowColor:
                  selected == options[index] ? AppColors.primary : null,
              child: Row(
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withAlpha(24),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppDirectionalText(
                      options[index],
                      languageCode: 'de',
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
                        : Colors.grey,
                  ),
                ],
              ),
            ),
            if (index != options.length - 1) const SizedBox(height: 8),
          ],
        ],
      );
}

final class _CheckButton extends StatelessWidget {
  const _CheckButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: enabled ? onTap : null,
        borderColor: enabled
            ? AppColors.mastery.withAlpha(100)
            : AppColors.primary.withAlpha(30),
        glowColor: enabled ? AppColors.mastery : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.fact_check_rounded,
              color: enabled ? AppColors.mastery : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              'تحقق من الإجابة',
              style: AppTypography.title.copyWith(
                color: enabled ? AppColors.mastery : Colors.grey,
              ),
            ),
          ],
        ),
      );
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.challenge,
    required this.isCorrect,
    required this.explanation,
    required this.dark,
  });

  final KonjunktivChallengeItem challenge;
  final bool isCorrect;
  final String explanation;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.mastery : AppColors.tertiary;
    return AppGlassCard(
      borderColor: color.withAlpha(92),
      glowColor: color,
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.lightbulb_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'صحيح' : 'راجع الصيغة',
                style: AppTypography.title.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppDirectionalText(
            challenge.konjunktivSentence,
            languageCode: 'de',
            style: AppTypography.title.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.arabicTranslation,
            style: AppTypography.body,
          ),
          const SizedBox(height: 10),
          Text(
            explanation,
            style: AppTypography.body,
          ),
          const SizedBox(height: 10),
          _FormBadge(formType: challenge.formType),
        ],
      ),
    );
  }
}

final class _FormBadge extends StatelessWidget {
  const _FormBadge({required this.formType});

  final KonjunktivFormType formType;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.primary.withAlpha(18),
          border: Border.all(color: AppColors.primary.withAlpha(54)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.schema_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                formType.label,
                textDirection: TextDirection.ltr,
                style: AppTypography.label.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isBusy,
    required this.message,
    required this.onRetry,
  });

  final bool isBusy;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.psychology_alt_rounded,
                color: AppColors.tertiary,
                size: 38,
              ),
              const SizedBox(height: 10),
              Text(
                message ?? 'لا توجد تحديات متاحة.',
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
