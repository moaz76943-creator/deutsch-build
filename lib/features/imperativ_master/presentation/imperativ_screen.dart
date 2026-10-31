import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/imperativ_notifier.dart';
import '../domain/imperativ_models.dart';

class ImperativScreen extends StatefulWidget {
  const ImperativScreen({required this.notifier, super.key});

  final ImperativNotifier notifier;

  @override
  State<ImperativScreen> createState() => _ImperativScreenState();
}

class _ImperativScreenState extends State<ImperativScreen> {
  String _draft = '';

  void _filter(ImperativTarget target) {
    _draft = '';
    widget.notifier.filterByTarget(target);
  }

  void _next() {
    _draft = '';
    widget.notifier.nextDrill();
  }

  String _contextForDisplay(
    ImperativDrillItem item, {
    required bool reveal,
  }) {
    if (reveal) return item.contextSentence;
    final canonical = item.correctForm.replaceAll(
      RegExp(r'[.!?…]+$'),
      '',
    );
    return item.contextSentence.replaceFirst(canonical, '_____');
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('Imperativ Master')),
          body: AnimatedBuilder(
            animation: widget.notifier,
            builder: (context, _) {
              final state = widget.notifier.state;
              final item = state.current;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  AppGlassCard(
                    glowColor: AppColors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'اختر الشخص المخاطَب',
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final target in ImperativTarget.values)
                              ChoiceChip(
                                label: Text(target.labelAr),
                                selected: state.filter == target,
                                selectedColor: AppColors.primary.withAlpha(35),
                                side: BorderSide(
                                  color: state.filter == target
                                      ? AppColors.primary
                                      : Theme.of(context).dividerColor,
                                ),
                                onSelected: (_) => _filter(target),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppGlassCard(
                    glowColor: AppColors.secondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.record_voice_over_rounded,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.target.labelAr,
                                style: AppTypography.title,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.infinitive,
                          textDirection: TextDirection.ltr,
                          style: AppTypography.display.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _contextForDisplay(item, reveal: state.checked),
                          textDirection: TextDirection.ltr,
                          style: AppTypography.body.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _MorphologyCard(
                    item: item,
                    revealAnswer: state.checked,
                  ),
                  const SizedBox(height: 14),
                  AppGlassCard(
                    glowColor: state.checked
                        ? (state.correct
                            ? AppColors.mastery
                            : AppColors.tertiary)
                        : AppColors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'اكتب صيغة الأمر',
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          key: ValueKey<String>(
                            '${item.id}-${state.currentIndex}',
                          ),
                          initialValue: _draft,
                          enabled: !state.checked,
                          textDirection: TextDirection.ltr,
                          autocorrect: false,
                          enableSuggestions: false,
                          onChanged: (value) => _draft = value,
                          onFieldSubmitted: state.checked
                              ? null
                              : widget.notifier.checkImperativForm,
                          decoration: const InputDecoration(
                            hintText: 'اكتب صيغة الأمر كاملة',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!state.checked)
                          FilledButton.icon(
                            onPressed: () =>
                                widget.notifier.checkImperativForm(_draft),
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('تحقق'),
                          )
                        else ...[
                          _FeedbackBox(state: state),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: _next,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('التمرين التالي'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
}

class _MorphologyCard extends StatelessWidget {
  const _MorphologyCard({
    required this.item,
    required this.revealAnswer,
  });

  final ImperativDrillItem item;
  final bool revealAnswer;

  @override
  Widget build(BuildContext context) {
    final (removed, added) = _changeTokens(item);
    return AppGlassCard(
      glowColor: AppColors.achievement,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ماذا تغيّر؟', style: AppTypography.title),
          const SizedBox(height: 8),
          Text(
            revealAnswer
                ? '${item.referenceForm}  →  ${item.correctForm}'
                : '${item.referenceForm}  →  _____',
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChangeToken(
                label: 'محذوف / متغيّر',
                value: removed,
                color: AppColors.tertiary,
              ),
              _ChangeToken(
                label: 'المضاف / الناتج',
                value: added,
                color: AppColors.mastery,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.vowelChange.labelAr,
            style: AppTypography.label.copyWith(
              color: AppColors.achievement,
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _changeTokens(ImperativDrillItem item) {
    if (item.vowelChange == ImperativVowelChange.eToI) {
      return ('e + du/-st', 'i');
    }
    if (item.vowelChange == ImperativVowelChange.eToIe) {
      return ('e + du/-st', 'ie');
    }
    if (item.vowelChange == ImperativVowelChange.umlautDropped) {
      return ('Umlaut + du/-st', 'a/o/u');
    }
    if (item.vowelChange == ImperativVowelChange.irregularSein) {
      return ('bist / seid / sind', 'sei / seid / seien');
    }
    return switch (item.target) {
      ImperativTarget.duForm => ('du + -st', 'جذر الفعل'),
      ImperativTarget.ihrForm => ('ihr', 'صيغة ihr بلا ضمير'),
      ImperativTarget.sieForm => ('—', 'المصدر + Sie'),
      ImperativTarget.wirForm => ('—', 'المصدر + wir'),
    };
  }
}

class _ChangeToken extends StatelessWidget {
  const _ChangeToken({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: color.withAlpha(24),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(95)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.label.copyWith(color: color),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ),
      );
}

class _FeedbackBox extends StatelessWidget {
  const _FeedbackBox({required this.state});

  final ImperativState state;

  @override
  Widget build(BuildContext context) {
    final color = state.correct ? AppColors.mastery : AppColors.tertiary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              state.correct ? 'إجابة صحيحة' : 'راجع الصيغة',
              style: AppTypography.label.copyWith(color: color),
            ),
            const SizedBox(height: 6),
            if (!state.correct)
              Text(
                state.current.correctForm,
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            const SizedBox(height: 6),
            Text(state.feedbackAr, style: AppTypography.body),
          ],
        ),
      ),
    );
  }
}
