import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/berufssprache_notifier.dart';
import '../domain/berufssprache_models.dart';

abstract final class BerufsspracheUiTokens {
  static const double page = 16;
  static const double top = 18;
  static const double bottom = 28;
  static const double gapXs = 6;
  static const double gapSm = 10;
  static const double gapMd = 14;
  static const double icon = 34;
  static const double chipHorizontal = 12;
  static const double chipVertical = 9;
}

final class BerufsspracheScreen extends StatefulWidget {
  const BerufsspracheScreen({required this.notifier, super.key});

  final BerufsspracheNotifier notifier;

  @override
  State<BerufsspracheScreen> createState() => _BerufsspracheScreenState();
}

final class _BerufsspracheScreenState extends State<BerufsspracheScreen> {
  final TextEditingController _practiceController = TextEditingController();

  BerufsspracheNotifier get notifier => widget.notifier;

  @override
  void initState() {
    super.initState();
    notifier.addListener(_refresh);
    if (notifier.currentPhrase == null) {
      unawaited(notifier.load());
    }
  }

  @override
  void didUpdateWidget(covariant BerufsspracheScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier == notifier) return;
    oldWidget.notifier.removeListener(_refresh);
    notifier.addListener(_refresh);
    _practiceController.clear();
  }

  @override
  void dispose() {
    notifier.removeListener(_refresh);
    _practiceController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _selectTopic(WorkplaceTopic? topic) async {
    _practiceController.clear();
    await notifier.filterByTopic(topic);
  }

  Future<void> _check() async {
    final value = _practiceController.text.trim();
    if (value.isEmpty || notifier.isBusy) return;
    await notifier.checkGerman(value);
  }

  void _next() {
    _practiceController.clear();
    notifier.nextPhrase();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final phrase = notifier.currentPhrase;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              BerufsspracheUiTokens.page,
              BerufsspracheUiTokens.top,
              BerufsspracheUiTokens.page,
              BerufsspracheUiTokens.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(surface: surface, border: border),
                const SizedBox(height: BerufsspracheUiTokens.gapMd),
                _TopicSelector(
                  activeTopic: notifier.activeTopic,
                  enabled: !notifier.isBusy,
                  surface: surface,
                  border: border,
                  onSelected: (topic) => unawaited(_selectTopic(topic)),
                ),
                if (notifier.activeTopic == WorkplaceTopic.meetingMinutes)
                  ...<Widget>[
                    const SizedBox(height: BerufsspracheUiTokens.gapMd),
                    _ProtocolCard(surface: surface, border: border),
                  ],
                const SizedBox(height: BerufsspracheUiTokens.gapMd),
                if (phrase == null)
                  _EmptyCard(
                    busy: notifier.isBusy,
                    surface: surface,
                    border: border,
                    onRetry: () => unawaited(notifier.load()),
                  )
                else ...<Widget>[
                  _PhraseCard(
                    phrase: phrase,
                    showArabic: notifier.showArabic,
                    surface: surface,
                    border: border,
                    onToggleArabic: notifier.toggleArabic,
                  ),
                  const SizedBox(height: BerufsspracheUiTokens.gapMd),
                  _PracticeCard(
                    controller: _practiceController,
                    phrase: phrase,
                    notifier: notifier,
                    surface: surface,
                    border: border,
                    onCheck: () => unawaited(_check()),
                    onClear: () {
                      _practiceController.clear();
                      notifier.clearAnswer();
                    },
                  ),
                  const SizedBox(height: BerufsspracheUiTokens.gapMd),
                  _NextCard(
                    enabled: !notifier.isBusy,
                    surface: surface,
                    onTap: _next,
                  ),
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
  const _HeaderCard({required this.surface, required this.border});

  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.primary,
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.business_center_rounded,
              color: AppColors.primary,
              size: BerufsspracheUiTokens.icon,
            ),
            const SizedBox(width: BerufsspracheUiTokens.gapSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDirectionalText(
                    'لغة العمل والتواصل المهني',
                    languageCode: 'ar',
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: BerufsspracheUiTokens.gapXs),
                  AppDirectionalText(
                    'Berufssprache & Fachdeutsch',
                    languageCode: 'de',
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

final class _TopicSelector extends StatelessWidget {
  const _TopicSelector({
    required this.activeTopic,
    required this.enabled,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final WorkplaceTopic? activeTopic;
  final bool enabled;
  final Color surface;
  final Color border;
  final ValueChanged<WorkplaceTopic?> onSelected;

  @override
  Widget build(BuildContext context) {
    final topics = <WorkplaceTopic?>[null, ...WorkplaceTopic.values];
    return Wrap(
      spacing: BerufsspracheUiTokens.gapSm,
      runSpacing: BerufsspracheUiTokens.gapSm,
      children: <Widget>[
        for (final topic in topics)
          AppGlassCard(
            onTap: enabled ? () => onSelected(topic) : null,
            backgroundColor: surface,
            padding: const EdgeInsets.symmetric(
              horizontal: BerufsspracheUiTokens.chipHorizontal,
              vertical: BerufsspracheUiTokens.chipVertical,
            ),
            borderColor: activeTopic == topic ? AppColors.secondary : border,
            glowColor: activeTopic == topic ? AppColors.secondary : null,
            child: AppDirectionalText(
              topic?.arabicLabel ?? 'كل موضوعات العمل',
              languageCode: 'ar',
              style: AppTypography.label.copyWith(
                color: activeTopic == topic ? AppColors.secondary : null,
              ),
            ),
          ),
      ],
    );
  }
}

final class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.phrase,
    required this.showArabic,
    required this.surface,
    required this.border,
    required this.onToggleArabic,
  });

  final WorkplacePhrase phrase;
  final bool showArabic;
  final Color surface;
  final Color border;
  final VoidCallback onToggleArabic;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.tertiary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              phrase.topic.germanLabel,
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.tertiary),
            ),
            const SizedBox(height: BerufsspracheUiTokens.gapSm),
            AppDirectionalText(
              phrase.german,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: BerufsspracheUiTokens.gapSm),
            AppDirectionalText(
              phrase.register.germanLabel,
              languageCode: 'de',
              style: AppTypography.label.copyWith(color: AppColors.secondary),
            ),
            if (showArabic) ...<Widget>[
              const SizedBox(height: BerufsspracheUiTokens.gapSm),
              AppDirectionalText(
                phrase.arabic,
                languageCode: 'ar',
                style: AppTypography.body,
              ),
              const SizedBox(height: BerufsspracheUiTokens.gapXs),
              AppDirectionalText(
                phrase.usageArabic,
                languageCode: 'ar',
                style: AppTypography.label,
              ),
            ],
            const SizedBox(height: BerufsspracheUiTokens.gapSm),
            AppGlassCard(
              onTap: onToggleArabic,
              borderColor: AppColors.secondary,
              child: AppDirectionalText(
                showArabic ? 'إخفاء الشرح العربي' : 'إظهار الشرح العربي',
                languageCode: 'ar',
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      );
}

final class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.controller,
    required this.phrase,
    required this.notifier,
    required this.surface,
    required this.border,
    required this.onCheck,
    required this.onClear,
  });

  final TextEditingController controller;
  final WorkplacePhrase phrase;
  final BerufsspracheNotifier notifier;
  final Color surface;
  final Color border;
  final VoidCallback onCheck;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final result = notifier.lastAnswerCorrect;
    final accent = result == null
        ? AppColors.primary
        : result
            ? AppColors.mastery
            : AppColors.tertiary;

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: result == null ? border : accent,
      glowColor: result == null ? null : accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'تدريب الاسترجاع: اكتب العبارة الألمانية',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: BerufsspracheUiTokens.gapSm),
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: controller,
              enabled: !notifier.isBusy,
              style: AppTypography.body,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: phrase.topic.germanLabel,
              ),
              onSubmitted: (_) => onCheck(),
            ),
          ),
          const SizedBox(height: BerufsspracheUiTokens.gapSm),
          Row(
            children: <Widget>[
              Expanded(
                child: AppGlassCard(
                  onTap: notifier.isBusy ? null : onCheck,
                  borderColor: AppColors.mastery,
                  child: AppDirectionalText(
                    'تحقق',
                    languageCode: 'ar',
                    textAlign: TextAlign.center,
                    style: AppTypography.label.copyWith(
                      color: AppColors.mastery,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: BerufsspracheUiTokens.gapSm),
              Expanded(
                child: AppGlassCard(
                  onTap: notifier.isBusy ? null : onClear,
                  borderColor: AppColors.secondary,
                  child: AppDirectionalText(
                    'مسح',
                    languageCode: 'ar',
                    textAlign: TextAlign.center,
                    style: AppTypography.label.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (result != null) ...<Widget>[
            const SizedBox(height: BerufsspracheUiTokens.gapSm),
            AppDirectionalText(
              notifier.feedbackArabic ?? '',
              languageCode: 'ar',
              style: AppTypography.body.copyWith(color: accent),
            ),
          ],
        ],
      ),
    );
  }
}

final class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard({required this.surface, required this.border});

  final Color surface;
  final Color border;

  static const ProtocolDraft sample = ProtocolDraft(
    date: '12.10.2026',
    participants: <String>['Frau Keller', 'Herr Berger'],
    discussionPoints: <String>[
      'Zeitplan für die interne Schulung',
      'Prüfung der Arbeitsunterlagen',
    ],
    decisions: <String>[
      'Die Schulung findet am Donnerstagvormittag statt.',
    ],
    tasks: <ProtocolTask>[
      ProtocolTask(
        task: 'Unterlagen vorbereiten',
        responsible: 'Frau Keller',
        deadline: 'Mittwoch',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: AppColors.achievement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Musterprotokoll',
              languageCode: 'de',
              style: AppTypography.title.copyWith(
                color: AppColors.achievement,
              ),
            ),
            const SizedBox(height: BerufsspracheUiTokens.gapSm),
            AppDirectionalText(
              sample.renderGerman(),
              languageCode: 'de',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _NextCard extends StatelessWidget {
  const _NextCard({
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
        borderColor: AppColors.primary,
        glowColor: enabled ? AppColors.primary : null,
        child: AppDirectionalText(
          'العبارة التالية',
          languageCode: 'ar',
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(color: AppColors.primary),
        ),
      );
}

final class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.busy,
    required this.surface,
    required this.border,
    required this.onRetry,
  });

  final bool busy;
  final Color surface;
  final Color border;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: busy ? null : onRetry,
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          children: <Widget>[
            if (busy)
              const CircularProgressIndicator(color: AppColors.primary)
            else
              const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: BerufsspracheUiTokens.icon,
              ),
            const SizedBox(height: BerufsspracheUiTokens.gapSm),
            AppDirectionalText(
              busy ? 'يتم تجهيز المحتوى المهني...' : 'لا توجد عبارات متاحة.',
              languageCode: 'ar',
              textAlign: TextAlign.center,
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
