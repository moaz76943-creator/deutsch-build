import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/separable_verbs_notifier.dart';
import '../domain/separable_verbs_models.dart';

final class SeparableVerbsScreen extends StatefulWidget {
  const SeparableVerbsScreen({
    required this.notifier,
    super.key,
  });

  final SeparableVerbsNotifier notifier;

  @override
  State<SeparableVerbsScreen> createState() => _SeparableVerbsScreenState();
}

final class _SeparableVerbsScreenState extends State<SeparableVerbsScreen> {
  PrefixPlacement? _placement;
  String? _conjugation;
  String? _lastDrillId;

  SeparableVerbsNotifier get notifier => widget.notifier;

  @override
  void initState() {
    super.initState();
    notifier.addListener(_onNotifierChanged);
    unawaited(notifier.initialize());
  }

  @override
  void didUpdateWidget(covariant SeparableVerbsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier == notifier) return;
    oldWidget.notifier.removeListener(_onNotifierChanged);
    notifier.addListener(_onNotifierChanged);
    _placement = null;
    _conjugation = null;
    _lastDrillId = null;
    unawaited(notifier.initialize());
  }

  @override
  void dispose() {
    notifier.removeListener(_onNotifierChanged);
    super.dispose();
  }

  void _onNotifierChanged() {
    if (!mounted) return;
    final currentId = notifier.currentVerb?.id;
    if (currentId != _lastDrillId) {
      _lastDrillId = currentId;
      _placement = null;
      _conjugation = null;
    }
    setState(() {});
  }

  void _selectPlacement(PrefixPlacement placement) {
    setState(() => _placement = placement);
  }

  void _selectConjugation(String conjugation) {
    setState(() => _conjugation = conjugation);
  }

  void _verify() {
    final placement = _placement;
    final conjugation = _conjugation;
    if (placement == null || conjugation == null || notifier.isBusy) return;
    unawaited(
      notifier.checkPrefixPlacement(
        placement,
        conjugatedVerb: conjugation,
      ),
    );
  }

  void _next() {
    notifier.nextDrill();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final item = notifier.currentVerb;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: Text('الأفعال الانفصالية والمتصلة', style: AppTypography.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: item == null
              ? Center(
                  child: notifier.isBusy
                      ? const CircularProgressIndicator()
                      : Text(
                          'لا توجد تمارين متاحة.',
                          style: AppTypography.body,
                        ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  children: <Widget>[
                    _FilterRow(
                      activeFilter: notifier.activeFilter,
                      onAll: notifier.clearFilter,
                      onType: (type) =>
                          unawaited(notifier.filterByType(type)),
                    ),
                    const SizedBox(height: 12),
                    _HeaderCard(
                      item: item,
                      drillNumber: notifier.drillNumber,
                      drillCount: notifier.drillCount,
                      dark: dark,
                    ),
                    const SizedBox(height: 12),
                    _DetachmentIndicator(
                      item: item,
                      selectedPlacement: _placement,
                      checkedPlacement: notifier.selectedPlacement,
                      isCorrect: notifier.isCorrect,
                      dark: dark,
                    ),
                    const SizedBox(height: 12),
                    _SentenceCard(item: item, dark: dark),
                    const SizedBox(height: 12),
                    _ConjugationCard(
                      item: item,
                      selected: _conjugation,
                      onSelected: _selectConjugation,
                      dark: dark,
                    ),
                    const SizedBox(height: 12),
                    _PlacementCard(
                      selected: _placement,
                      onSelected: _selectPlacement,
                      dark: dark,
                    ),
                    const SizedBox(height: 12),
                    AppGlassCard(
                      onTap: _placement == null ||
                              _conjugation == null ||
                              notifier.isBusy
                          ? null
                          : _verify,
                      glowColor: AppColors.mastery,
                      borderColor: AppColors.mastery.withAlpha(84),
                      backgroundColor:
                          dark ? AppColors.darkSurface : AppColors.lightSurface,
                      child: Center(
                        child: Text(
                          notifier.isBusy ? 'جارٍ التحقق…' : 'تحقق من الإجابة',
                          style: AppTypography.title.copyWith(
                            color: AppColors.mastery,
                          ),
                        ),
                      ),
                    ),
                    if (notifier.explanation.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _FeedbackCard(
                        explanation: notifier.explanation,
                        isCorrect: notifier.isCorrect,
                        dark: dark,
                      ),
                      const SizedBox(height: 12),
                      AppGlassCard(
                        onTap: _next,
                        glowColor: AppColors.primary,
                        backgroundColor:
                            dark ? AppColors.darkSurface : AppColors.lightSurface,
                        child: Center(
                          child: Text(
                            'التمرين التالي',
                            style: AppTypography.title.copyWith(
                              color: dark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                            ),
                          ),
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

final class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.activeFilter,
    required this.onAll,
    required this.onType,
  });

  final PrefixType? activeFilter;
  final VoidCallback onAll;
  final ValueChanged<PrefixType> onType;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _FilterChipCard(
              label: 'الكل',
              selected: activeFilter == null,
              onTap: onAll,
            ),
            const SizedBox(width: 8),
            for (final type in PrefixType.values) ...[
              _FilterChipCard(
                label: _typeLabel(type),
                selected: activeFilter == type,
                onTap: () => onType(type),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      );

  static String _typeLabel(PrefixType type) => switch (type) {
        PrefixType.separable => 'انفصالي',
        PrefixType.inseparable => 'متصل',
        PrefixType.dualVariable => 'متغير',
      };
}

final class _FilterChipCard extends StatelessWidget {
  const _FilterChipCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        borderRadius: 20,
        glowColor: selected ? AppColors.primary : null,
        borderColor: AppColors.primary.withAlpha(selected ? 120 : 54),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: selected ? AppColors.primary : null,
          ),
        ),
      );
}

final class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.item,
    required this.drillNumber,
    required this.drillCount,
    required this.dark,
  });

  final VerbPrefixDrillItem item;
  final int drillNumber;
  final int drillCount;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        borderColor:
            dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: AppDirectionalText(
                    item.fullInfinitive,
                    languageCode: 'de',
                    style: AppTypography.display.copyWith(
                      color: dark ? Colors.white : AppColors.darkSurface,
                    ),
                  ),
                ),
                Text(
                  '$drillNumber / $drillCount',
                  style: AppTypography.label.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _Tag(label: 'Prefix: ${item.prefix}', color: AppColors.tertiary),
                _Tag(label: 'Root: ${item.rootVerb}', color: AppColors.secondary),
                _Tag(
                  label: _typeLabel(item.prefixType),
                  color: AppColors.achievement,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.meaningExplanationAr,
              style: AppTypography.body.copyWith(
                color: dark ? Colors.white70 : AppColors.darkSurface,
              ),
            ),
          ],
        ),
      );

  static String _typeLabel(PrefixType type) => switch (type) {
        PrefixType.separable => 'سابقة انفصالية',
        PrefixType.inseparable => 'سابقة غير انفصالية',
        PrefixType.dualVariable => 'سابقة متغيرة حسب المعنى',
      };
}

final class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withAlpha(22),
          border: Border.all(color: color.withAlpha(72)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: AppTypography.label.copyWith(color: color),
          ),
        ),
      );
}

final class _DetachmentIndicator extends StatelessWidget {
  const _DetachmentIndicator({
    required this.item,
    required this.selectedPlacement,
    required this.checkedPlacement,
    required this.isCorrect,
    required this.dark,
  });

  final VerbPrefixDrillItem item;
  final PrefixPlacement? selectedPlacement;
  final PrefixPlacement? checkedPlacement;
  final bool? isCorrect;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final requested = checkedPlacement ?? selectedPlacement;
    final displayPlacement = isCorrect == false
        ? item.expectedPlacement
        : requested;
    final showDetached =
        displayPlacement == PrefixPlacement.sentenceEndDetached;
    final corrective = isCorrect == false;

    return AppGlassCard(
      glowColor: corrective ? AppColors.tertiary : AppColors.achievement,
      borderColor: (corrective ? AppColors.tertiary : AppColors.achievement)
          .withAlpha(78),
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            corrective
                ? 'الموضع الصحيح'
                : 'مؤشر انفصال السابقة',
            style: AppTypography.label.copyWith(
              color: corrective ? AppColors.tertiary : AppColors.achievement,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: displayPlacement == null
                ? Directionality(
                    key: const ValueKey<String>('neutral'),
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _VerbPart(text: item.prefix, accent: AppColors.tertiary),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.add_rounded, size: 20),
                        ),
                        _VerbPart(text: item.rootVerb, accent: AppColors.primary),
                      ],
                    ),
                  )
                : showDetached
                    ? Directionality(
                        key: const ValueKey<String>('detached'),
                        textDirection: TextDirection.ltr,
                        child: Row(
                          children: <Widget>[
                            _VerbPart(
                              text: item.expectedConjugatedVerb,
                              accent: AppColors.primary,
                            ),
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Divider(),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.achievement,
                            ),
                            const SizedBox(width: 8),
                            _VerbPart(
                              text: item.prefix,
                              accent: AppColors.achievement,
                            ),
                          ],
                        ),
                      )
                    : Directionality(
                        key: const ValueKey<String>('attached'),
                        textDirection: TextDirection.ltr,
                        child: Center(
                          child: _VerbPart(
                            text: item.expectedConjugatedVerb,
                            accent: AppColors.primary,
                          ),
                        ),
                      ),
          ),
          if (displayPlacement != null) ...[
            const SizedBox(height: 10),
            Text(
              showDetached
                  ? 'الفعل المصرف في Position 2، والسابقة في Satzende.'
                  : 'السابقة تبقى متصلة بالفعل المصرف في Position 2.',
              textAlign: TextAlign.center,
              style: AppTypography.label.copyWith(
                color: dark ? Colors.white70 : AppColors.darkSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

final class _VerbPart extends StatelessWidget {
  const _VerbPart({
    required this.text,
    required this.accent,
  });

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: accent.withAlpha(24),
          border: Border.all(color: accent.withAlpha(88)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: AppDirectionalText(
            text,
            languageCode: 'de',
            style: AppTypography.body.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
}

final class _SentenceCard extends StatelessWidget {
  const _SentenceCard({
    required this.item,
    required this.dark,
  });

  final VerbPrefixDrillItem item;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor:
            dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('الجملة التفاعلية', style: AppTypography.title),
            const SizedBox(height: 10),
            AppDirectionalText(
              item.trainingSentenceTemplate,
              languageCode: 'de',
              style: AppTypography.title.copyWith(
                color: dark ? Colors.white : AppColors.darkSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.arabicTranslation,
              style: AppTypography.body.copyWith(
                color: dark ? Colors.white70 : AppColors.darkSurface,
              ),
            ),
          ],
        ),
      );
}

final class _ConjugationCard extends StatelessWidget {
  const _ConjugationCard({
    required this.item,
    required this.selected,
    required this.onSelected,
    required this.dark,
  });

  final VerbPrefixDrillItem item;
  final String? selected;
  final ValueChanged<String> onSelected;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.primary.withAlpha(72),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'اختر تصريف الفعل في Position 2',
              style: AppTypography.title.copyWith(
                color: dark ? Colors.white : AppColors.darkSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'الفاعل: ${item.subjectPronoun}',
              style: AppTypography.label.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final choice in item.conjugationChoices)
                  _ChoiceCard(
                    label: choice,
                    selected: selected == choice,
                    onTap: () => onSelected(choice),
                  ),
              ],
            ),
          ],
        ),
      );
}

final class _PlacementCard extends StatelessWidget {
  const _PlacementCard({
    required this.selected,
    required this.onSelected,
    required this.dark,
  });

  final PrefixPlacement? selected;
  final ValueChanged<PrefixPlacement> onSelected;
  final bool dark;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        borderColor: AppColors.achievement.withAlpha(72),
        backgroundColor:
            dark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'أين توضع السابقة؟',
              style: AppTypography.title.copyWith(
                color: dark ? Colors.white : AppColors.darkSurface,
              ),
            ),
            const SizedBox(height: 10),
            _ChoiceCard(
              label: 'متصلة بالفعل في Position 2',
              selected: selected == PrefixPlacement.position2Attached,
              onTap: () => onSelected(PrefixPlacement.position2Attached),
            ),
            const SizedBox(height: 8),
            _ChoiceCard(
              label: 'منفصلة في Satzende',
              selected: selected == PrefixPlacement.sentenceEndDetached,
              onTap: () => onSelected(PrefixPlacement.sentenceEndDetached),
            ),
          ],
        ),
      );
}

final class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: 20,
        glowColor: selected ? AppColors.primary : null,
        borderColor: AppColors.primary.withAlpha(selected ? 118 : 54),
        child: AppDirectionalText(
          label,
          languageCode: RegExp(r'[\u0600-\u06FF]').hasMatch(label) ? 'ar' : 'de',
          style: AppTypography.body.copyWith(
            color: selected ? AppColors.primary : null,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      );
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.explanation,
    required this.isCorrect,
    required this.dark,
  });

  final String explanation;
  final bool? isCorrect;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final accent = isCorrect == true ? AppColors.mastery : AppColors.tertiary;
    return AppGlassCard(
      glowColor: accent,
      borderColor: accent.withAlpha(82),
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
              explanation,
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
