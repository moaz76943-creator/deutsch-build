import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/partizip_notifier.dart';
import '../domain/partizip_models.dart';

class PartizipScreen extends StatefulWidget {
  const PartizipScreen({required this.notifier, super.key});

  final PartizipNotifier notifier;

  @override
  State<PartizipScreen> createState() => _PartizipScreenState();
}

class _PartizipScreenState extends State<PartizipScreen> {
  String _draft = '';

  void _filter(PartizipKind kind) {
    _draft = '';
    widget.notifier.filterByKind(kind);
  }

  void _next() {
    _draft = '';
    widget.notifier.nextExercise();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: AppDirectionalText(
            'Partizip I & II als Attribute',
            languageCode: 'de',
            style: AppTypography.title,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: AnimatedBuilder(
              animation: widget.notifier,
              builder: (context, _) {
                final state = widget.notifier.state;
                final exercise = state.current;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _KindFilterCard(
                      selected: state.filter,
                      onSelected: _filter,
                    ),
                    const SizedBox(height: 14),
                    _ConceptCard(exercise: exercise),
                    const SizedBox(height: 14),
                    _TokenOrderCard(
                      state: state,
                      onAdd: widget.notifier.addToken,
                      onUndo: widget.notifier.removeLastToken,
                      onCheck: widget.notifier.checkTokenOrder,
                    ),
                    const SizedBox(height: 14),
                    _AnswerCard(
                      state: state,
                      draft: _draft,
                      onChanged: (value) => _draft = value,
                      onCheck: () =>
                          widget.notifier.checkAttribute(_draft),
                      onNext: _next,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}

class _KindFilterCard extends StatelessWidget {
  const _KindFilterCard({
    required this.selected,
    required this.onSelected,
  });

  final PartizipKind? selected;
  final ValueChanged<PartizipKind> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              'اختر نوع الـ Partizip',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in PartizipKind.values)
                  ChoiceChip(
                    label: AppDirectionalText(
                      kind.labelDe,
                      languageCode: 'de',
                      style: AppTypography.label,
                    ),
                    selected: selected == kind,
                    selectedColor: AppColors.primary.withAlpha(30),
                    side: BorderSide(
                      color: selected == kind
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                    onSelected: (_) => onSelected(kind),
                  ),
              ],
            ),
          ],
        ),
      );
}

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({required this.exercise});

  final PartizipExercise exercise;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: exercise.kind == PartizipKind.partizipI
            ? AppColors.secondary
            : AppColors.achievement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  value: exercise.kind.labelDe,
                  languageCode: 'de',
                ),
                _InfoPill(
                  value: exercise.scope.labelAr,
                  languageCode: 'ar',
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppDirectionalText(
              '${exercise.infinitive} → ${exercise.participle}',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              exercise.sourceSentenceDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            const SizedBox(height: 8),
            AppDirectionalText(
              exercise.translationAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

class _TokenOrderCard extends StatelessWidget {
  const _TokenOrderCard({
    required this.state,
    required this.onAdd,
    required this.onUndo,
    required this.onCheck,
  });

  final PartizipState state;
  final ValueChanged<String> onAdd;
  final VoidCallback onUndo;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final exercise = state.current;
    final available = List<String>.from(exercise.attributeTokens);
    for (final selected in state.orderedTokens) {
      available.remove(selected);
    }

    return AppGlassCard(
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDirectionalText(
            'رتّب الوصف الألماني الموسّع قبل الاسم',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final token in state.orderedTokens)
                  Chip(label: Text(token)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final token in available)
                  ActionChip(
                    label: Text(token),
                    onPressed: state.checked
                        ? null
                        : () => onAdd(token),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.checked ? null : onUndo,
                  icon: const Icon(Icons.undo_rounded),
                  label: AppDirectionalText(
                    'تراجع',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.checked ? null : onCheck,
                  icon: const Icon(Icons.check_rounded),
                  label: AppDirectionalText(
                    'تحقق من الترتيب',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.state,
    required this.draft,
    required this.onChanged,
    required this.onCheck,
    required this.onNext,
  });

  final PartizipState state;
  final String draft;
  final ValueChanged<String> onChanged;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: state.checked
            ? (state.correct ? AppColors.mastery : AppColors.tertiary)
            : AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              'اكتب المجموعة الوصفية كاملة',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: ValueKey<String>(
                '${state.current.id}-${state.currentIndex}',
              ),
              initialValue: draft,
              enabled: !state.checked,
              textDirection: TextDirection.ltr,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: onChanged,
              onFieldSubmitted: state.checked ? null : (_) => onCheck(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Attributgruppe',
              ),
            ),
            const SizedBox(height: 12),
            if (!state.checked)
              FilledButton.icon(
                onPressed: onCheck,
                icon: const Icon(Icons.check_rounded),
                label: AppDirectionalText(
                  'تحقق',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              )
            else ...[
              _FeedbackPanel(state: state),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: AppDirectionalText(
                  'التمرين التالي',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ),
            ],
          ],
        ),
      );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.value,
    required this.languageCode,
  });

  final String value;
  final String languageCode;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withAlpha(80),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          child: AppDirectionalText(
            value,
            languageCode: languageCode,
            style: AppTypography.label,
          ),
        ),
      );
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({required this.state});

  final PartizipState state;

  @override
  Widget build(BuildContext context) {
    final accent = state.correct ? AppColors.mastery : AppColors.tertiary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withAlpha(90)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDirectionalText(
              state.current.correctAttribute,
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: accent),
            ),
            const SizedBox(height: 6),
            AppDirectionalText(
              state.feedbackAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}
