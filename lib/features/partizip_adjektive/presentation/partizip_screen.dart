import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/partizip_notifier.dart';
import '../domain/partizip_models.dart';

final class PartizipScreen extends StatefulWidget {
  const PartizipScreen({required this.notifier, super.key});

  final PartizipNotifier notifier;

  @override
  State<PartizipScreen> createState() => _PartizipScreenState();
}

final class _PartizipScreenState extends State<PartizipScreen> {
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
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        dark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: widget.notifier,
            builder: (context, _) {
              final state = widget.notifier.state;
              return ListView(
                children: <Widget>[
                  _HeaderCard(surface: surface, border: border),
                  Divider(color: border),
                  _KindFilterCard(
                    selected: state.filter,
                    surface: surface,
                    border: border,
                    onSelected: _filter,
                  ),
                  Divider(color: border),
                  _ConceptCard(
                    exercise: state.current,
                    surface: surface,
                    border: border,
                  ),
                  Divider(color: border),
                  _TokenOrderCard(
                    state: state,
                    surface: surface,
                    border: border,
                    onAdd: widget.notifier.addToken,
                    onUndo: widget.notifier.removeLastToken,
                    onCheck: widget.notifier.checkTokenOrder,
                  ),
                  Divider(color: border),
                  _AnswerCard(
                    state: state,
                    draft: _draft,
                    surface: surface,
                    border: border,
                    onChanged: (value) => _draft = value,
                    onCheck: () => widget.notifier.checkAttribute(_draft),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Partizip I & II als Adjektive',
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.primary),
            ),
            AppDirectionalText(
              'حوّل Partizip I وPartizip II إلى صفات، ثم تدرب على النعت التشاركي الموسّع قبل الاسم.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _KindFilterCard extends StatelessWidget {
  const _KindFilterCard({
    required this.selected,
    required this.surface,
    required this.border,
    required this.onSelected,
  });

  final PartizipKind? selected;
  final Color surface;
  final Color border;
  final ValueChanged<PartizipKind> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'اختر نوع الـ Partizip',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            for (final kind in PartizipKind.values)
              _GlassOption(
                selected: selected == kind,
                german: kind.labelDe,
                arabic: kind.labelAr,
                surface: surface,
                border: border,
                onTap: () => onSelected(kind),
              ),
          ],
        ),
      );
}

final class _ConceptCard extends StatelessWidget {
  const _ConceptCard({
    required this.exercise,
    required this.surface,
    required this.border,
  });

  final PartizipExercise exercise;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: exercise.kind == PartizipKind.partizipI
            ? AppColors.secondary
            : AppColors.achievement,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              exercise.kind.labelDe,
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: exercise.kind == PartizipKind.partizipI
                    ? AppColors.secondary
                    : AppColors.achievement,
              ),
            ),
            AppDirectionalText(
              exercise.scope.labelAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            AppDirectionalText(
              '${exercise.infinitive} → ${exercise.participle}',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            AppDirectionalText(
              exercise.correctAttribute,
              languageCode: 'de',
              style: AppTypography.title.copyWith(color: AppColors.primary),
            ),
            AppDirectionalText(
              exercise.sourceSentenceDe,
              languageCode: 'de',
              style: AppTypography.body,
            ),
            AppDirectionalText(
              exercise.translationAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _TokenOrderCard extends StatelessWidget {
  const _TokenOrderCard({
    required this.state,
    required this.surface,
    required this.border,
    required this.onAdd,
    required this.onUndo,
    required this.onCheck,
  });

  final PartizipState state;
  final Color surface;
  final Color border;
  final ValueChanged<String> onAdd;
  final VoidCallback onUndo;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final available = List<String>.from(state.current.attributeTokens);
    for (final selected in state.orderedTokens) {
      available.remove(selected);
    }

    return AppGlassCard(
      backgroundColor: surface,
      borderColor: border,
      glowColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            'رتّب الوصف الألماني قبل الاسم',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              children: <Widget>[
                for (final token in state.orderedTokens)
                  _TokenCard(
                    token: token,
                    surface: surface,
                    border: AppColors.primary,
                  ),
              ],
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              children: <Widget>[
                for (final token in available)
                  _TokenCard(
                    token: token,
                    surface: surface,
                    border: border,
                    onTap: state.checked ? null : () => onAdd(token),
                  ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionCard(
                  labelAr: 'تراجع',
                  icon: Icons.undo_rounded,
                  enabled: !state.checked && state.orderedTokens.isNotEmpty,
                  surface: surface,
                  border: border,
                  onTap: onUndo,
                ),
              ),
              Expanded(
                child: _ActionCard(
                  labelAr: 'تحقق من الترتيب',
                  icon: Icons.check_rounded,
                  enabled: !state.checked,
                  surface: surface,
                  border: AppColors.secondary,
                  onTap: onCheck,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.state,
    required this.draft,
    required this.surface,
    required this.border,
    required this.onChanged,
    required this.onCheck,
    required this.onNext,
  });

  final PartizipState state;
  final String draft;
  final Color surface;
  final Color border;
  final ValueChanged<String> onChanged;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        backgroundColor: surface,
        borderColor: border,
        glowColor: state.checked
            ? (state.correct ? AppColors.mastery : AppColors.tertiary)
            : AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'اكتب المجموعة الوصفية كاملة',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextFormField(
                key: ValueKey<String>(state.current.id),
                initialValue: draft,
                enabled: !state.checked,
                autocorrect: false,
                enableSuggestions: false,
                style: AppTypography.body,
                onChanged: onChanged,
                onFieldSubmitted: state.checked ? null : (_) => onCheck(),
                decoration: InputDecoration(
                  hintText: 'Attributgruppe',
                  hintStyle: AppTypography.label,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: border),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            if (!state.checked)
              _ActionCard(
                labelAr: 'تحقق',
                icon: Icons.check_rounded,
                enabled: true,
                surface: surface,
                border: AppColors.primary,
                onTap: onCheck,
              )
            else ...<Widget>[
              _FeedbackCard(
                state: state,
                surface: surface,
              ),
              _ActionCard(
                labelAr: 'التمرين التالي',
                icon: Icons.arrow_forward_rounded,
                enabled: true,
                surface: surface,
                border: AppColors.secondary,
                onTap: onNext,
              ),
            ],
          ],
        ),
      );
}

final class _GlassOption extends StatelessWidget {
  const _GlassOption({
    required this.selected,
    required this.german,
    required this.arabic,
    required this.surface,
    required this.border,
    required this.onTap,
  });

  final bool selected;
  final String german;
  final String arabic;
  final Color surface;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onTap,
        backgroundColor: surface,
        borderColor: selected ? AppColors.secondary : border,
        glowColor: selected ? AppColors.secondary : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              german,
              languageCode: 'de',
              style: AppTypography.label.copyWith(
                color: selected ? AppColors.secondary : null,
              ),
            ),
            AppDirectionalText(
              arabic,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _TokenCard extends StatelessWidget {
  const _TokenCard({
    required this.token,
    required this.surface,
    required this.border,
    this.onTap,
  });

  final String token;
  final Color surface;
  final Color border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: onTap,
        backgroundColor: surface,
        borderColor: border,
        child: AppDirectionalText(
          token,
          languageCode: 'de',
          style: AppTypography.label,
        ),
      );
}

final class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.labelAr,
    required this.icon,
    required this.enabled,
    required this.surface,
    required this.border,
    required this.onTap,
  });

  final String labelAr;
  final IconData icon;
  final bool enabled;
  final Color surface;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        onTap: enabled ? onTap : null,
        backgroundColor: surface,
        borderColor: enabled ? border : AppColors.glassBorderDark,
        glowColor: enabled ? border : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: enabled ? border : AppColors.glassBorderDark,
            ),
            Expanded(
              child: AppDirectionalText(
                labelAr,
                languageCode: 'ar',
                textAlign: TextAlign.center,
                style: AppTypography.label.copyWith(
                  color: enabled ? border : AppColors.glassBorderDark,
                ),
              ),
            ),
          ],
        ),
      );
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.state, required this.surface});

  final PartizipState state;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    final accent = state.correct ? AppColors.mastery : AppColors.tertiary;
    return AppGlassCard(
      backgroundColor: surface,
      borderColor: accent,
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppDirectionalText(
            state.current.correctAttribute,
            languageCode: 'de',
            style: AppTypography.title.copyWith(color: accent),
          ),
          AppDirectionalText(
            state.feedbackAr,
            languageCode: 'ar',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }
}
