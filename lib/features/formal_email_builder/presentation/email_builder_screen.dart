import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/email_builder_notifier.dart';
import '../domain/email_builder_models.dart';

final class EmailBuilderScreen extends StatefulWidget {
  const EmailBuilderScreen({
    required this.notifier,
    super.key,
  });

  final EmailBuilderNotifier notifier;

  @override
  State<EmailBuilderScreen> createState() => _EmailBuilderScreenState();
}

final class _EmailBuilderScreenState extends State<EmailBuilderScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.notifier.scenarios.isEmpty && !widget.notifier.isLoading) {
      unawaited(widget.notifier.load());
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'منشئ الإيميل الرسمي · E-Mail Builder',
              textDirection: TextDirection.rtl,
            ),
          ),
          body: SafeArea(
            child: ListenableBuilder(
              listenable: widget.notifier,
              builder: (context, _) {
                final notifier = widget.notifier;
                if (notifier.isLoading && notifier.scenarios.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (notifier.scenarios.isEmpty) {
                  return _EmptyState(
                    onRetry: () => unawaited(notifier.load()),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _ScenarioSelector(notifier: notifier),
                      const SizedBox(height: 14),
                      _RegisterGuide(scenario: notifier.activeScenario),
                      const SizedBox(height: 14),
                      _EmailPaper(notifier: notifier),
                      const SizedBox(height: 14),
                      for (final section in LetterSection.values) ...<Widget>[
                        _SectionPicker(
                          section: section,
                          notifier: notifier,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _ValidationPanel(notifier: notifier),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
}

final class _ScenarioSelector extends StatelessWidget {
  const _ScenarioSelector({required this.notifier});

  final EmailBuilderNotifier notifier;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(90),
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'اختر سيناريو المراسلة',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: notifier.activeScenario?.id,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<String>>[
                for (final scenario in notifier.scenarios)
                  DropdownMenuItem<String>(
                    value: scenario.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          scenario.titleAr + ' · ' + scenario.level,
                          textDirection: TextDirection.rtl,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          scenario.titleDe,
                          textDirection: TextDirection.ltr,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label,
                        ),
                      ],
                    ),
                  ),
              ],
              onChanged: notifier.isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        unawaited(notifier.selectScenario(value));
                      }
                    },
            ),
            if (notifier.activeScenario != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                notifier.activeScenario!.promptDe,
                textDirection: TextDirection.ltr,
                style: AppTypography.body,
              ),
            ],
          ],
        ),
      );
}

final class _RegisterGuide extends StatelessWidget {
  const _RegisterGuide({required this.scenario});

  final EmailScenario? scenario;

  @override
  Widget build(BuildContext context) {
    final active = scenario;
    if (active == null) return const SizedBox.shrink();

    return AppGlassCard(
      borderColor: AppColors.secondary.withAlpha(90),
      glowColor: AppColors.secondary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.tune_rounded,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'النبرة المطلوبة',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  _registerLabel(active.targetRegister),
                  textDirection: TextDirection.rtl,
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _registerLabel(EmailRegister register) => switch (register) {
        EmailRegister.formalOfficial => 'رسمي رسمي · Formal',
        EmailRegister.semiFormalWork => 'مهني شبه رسمي · Semi-formal',
        EmailRegister.informalFriendly => 'ودي غير رسمي · Informal',
      };
}

final class _EmailPaper extends StatelessWidget {
  const _EmailPaper({required this.notifier});

  final EmailBuilderNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;

    return AppGlassCard(
      backgroundColor: background,
      opacity: 1,
      borderColor: border,
      glowColor: AppColors.achievement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.mail_outline_rounded,
                color: AppColors.achievement,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'معاينة الرسالة',
                  textDirection: TextDirection.rtl,
                  style: AppTypography.title,
                ),
              ),
              Text(
                notifier.selectedBlocks.length.toString() +
                    ' / ' +
                    LetterSection.values.length.toString(),
                textDirection: TextDirection.ltr,
                style: AppTypography.label.copyWith(
                  color: AppColors.achievement,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final section in LetterSection.values) ...<Widget>[
            _PaperSection(
              section: section,
              block: notifier.selectedBlocks[section],
            ),
            if (section != LetterSection.values.last)
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

final class _PaperSection extends StatelessWidget {
  const _PaperSection({
    required this.section,
    required this.block,
  });

  final LetterSection section;
  final EmailTemplateBlock? block;

  @override
  Widget build(BuildContext context) {
    final selected = block;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: selected == null
                ? AppColors.glassBorderLight
                : AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _sectionLabel(section),
              textDirection: TextDirection.rtl,
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 5),
            if (selected == null)
              Text(
                '— اختر عبارة لهذا القسم —',
                textDirection: TextDirection.rtl,
                style: AppTypography.body,
              )
            else
              Text(
                selected.text,
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

final class _SectionPicker extends StatelessWidget {
  const _SectionPicker({
    required this.section,
    required this.notifier,
  });

  final LetterSection section;
  final EmailBuilderNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final options = notifier.blocksForSection(section);
    final selectedId = notifier.selectedBlocks[section]?.id;

    return AppGlassCard(
      borderColor: _sectionColor(section).withAlpha(80),
      glowColor: _sectionColor(section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                _sectionIcon(section),
                color: _sectionColor(section),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _sectionLabel(section),
                  textDirection: TextDirection.rtl,
                  style: AppTypography.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (options.isEmpty)
            Text(
              'لا توجد عبارات متاحة لهذا القسم.',
              textDirection: TextDirection.rtl,
              style: AppTypography.body,
            )
          else
            for (final block in options) ...<Widget>[
              _BlockOption(
                block: block,
                selected: selectedId == block.id,
                registerMismatch:
                    notifier.registerMismatchSections.contains(section) &&
                        selectedId == block.id,
                phraseIssue:
                    notifier.invalidPhraseSections.contains(section) &&
                        selectedId == block.id,
                onTap: () => unawaited(
                  notifier.selectSectionBlock(block.id),
                ),
              ),
              if (block != options.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  static Color _sectionColor(LetterSection section) => switch (section) {
        LetterSection.salutation => AppColors.primary,
        LetterSection.openingHook => AppColors.secondary,
        LetterSection.mainBodyReason => AppColors.achievement,
        LetterSection.requestOrComplaint => AppColors.tertiary,
        LetterSection.closingSignoff => AppColors.mastery,
      };

  static IconData _sectionIcon(LetterSection section) => switch (section) {
        LetterSection.salutation => Icons.waving_hand_outlined,
        LetterSection.openingHook => Icons.short_text_rounded,
        LetterSection.mainBodyReason => Icons.subject_rounded,
        LetterSection.requestOrComplaint => Icons.assignment_outlined,
        LetterSection.closingSignoff => Icons.draw_outlined,
      };
}

final class _BlockOption extends StatelessWidget {
  const _BlockOption({
    required this.block,
    required this.selected,
    required this.registerMismatch,
    required this.phraseIssue,
    required this.onTap,
  });

  final EmailTemplateBlock block;
  final bool selected;
  final bool registerMismatch;
  final bool phraseIssue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final issue = registerMismatch || phraseIssue;
    final border = issue
        ? AppColors.articleDie
        : selected
            ? AppColors.primary
            : AppColors.glassBorderLight;

    return AppGlassCard(
      onTap: onTap,
      borderRadius: 20,
      borderColor: border,
      glowColor: selected ? border : null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  block.text,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: border,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            block.translationAr,
            textDirection: TextDirection.rtl,
            style: AppTypography.body,
          ),
          const SizedBox(height: 8),
          _InfoLine(
            icon: Icons.record_voice_over_outlined,
            label: 'النبرة: ' + block.toneAr,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 6),
          _InfoLine(
            icon: Icons.format_quote_rounded,
            label: block.punctuationNoteAr,
            color: AppColors.tertiary,
          ),
          if (issue) ...<Widget>[
            const SizedBox(height: 8),
            _InfoLine(
              icon: Icons.warning_amber_rounded,
              label: registerMismatch
                  ? 'هذه العبارة لا تطابق درجة الرسمية المطلوبة لهذا السيناريو.'
                  : 'هذه العبارة تحتاج مراجعة قبل اعتمادها.',
              color: AppColors.articleDie,
            ),
          ],
        ],
      ),
    );
  }
}

final class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              textDirection: TextDirection.rtl,
              style: AppTypography.label.copyWith(color: color),
            ),
          ),
        ],
      );
}

final class _ValidationPanel extends StatelessWidget {
  const _ValidationPanel({required this.notifier});

  final EmailBuilderNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final valid = notifier.isStructureValid;
    final color = valid == true
        ? AppColors.mastery
        : valid == false
            ? AppColors.articleDie
            : AppColors.primary;

    return AppGlassCard(
      borderColor: color.withAlpha(100),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                valid == true
                    ? Icons.check_circle_outline_rounded
                    : Icons.fact_check_outlined,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  valid == true
                      ? 'هيكل الرسالة متناسق'
                      : valid == false
                          ? 'توجد نقاط تحتاج تصحيحاً'
                          : 'تحقق من بنية الرسالة',
                  textDirection: TextDirection.rtl,
                  style: AppTypography.title.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (notifier.registerMismatchSections.isNotEmpty)
            Text(
              'تنبيه: بعض الأقسام لا تطابق النبرة المطلوبة.',
              textDirection: TextDirection.rtl,
              style: AppTypography.body.copyWith(
                color: AppColors.articleDie,
              ),
            ),
          if (notifier.invalidPhraseSections.isNotEmpty)
            Text(
              'تنبيه: توجد عبارة غير معتمدة لهذا السياق.',
              textDirection: TextDirection.rtl,
              style: AppTypography.body.copyWith(
                color: AppColors.articleDie,
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.icon(
                onPressed: notifier.isComplete
                    ? () => unawaited(
                          notifier.validateLetterStructure(),
                        )
                    : null,
                icon: const Icon(Icons.verified_outlined),
                label: const Text(
                  'تحقق من الرسالة',
                  textDirection: TextDirection.rtl,
                ),
              ),
              OutlinedButton.icon(
                onPressed: notifier.resetTemplate,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text(
                  'إعادة البناء',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AppGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.mail_outline_rounded,
                color: AppColors.primary,
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد سيناريوهات مراسلة متاحة.',
                textDirection: TextDirection.rtl,
                style: AppTypography.title,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onRetry,
                child: const Text(
                  'إعادة التحميل',
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      );
}

String _sectionLabel(LetterSection section) => switch (section) {
      LetterSection.salutation => 'التحية · Anrede',
      LetterSection.openingHook => 'البداية · Einstieg',
      LetterSection.mainBodyReason => 'سبب الرسالة · Hauptteil',
      LetterSection.requestOrComplaint => 'الطلب أو الشكوى',
      LetterSection.closingSignoff => 'الخاتمة · Grußformel',
    };
