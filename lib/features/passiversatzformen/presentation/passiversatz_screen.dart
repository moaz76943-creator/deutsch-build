import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/passiversatz_engine.dart';
import '../domain/passiversatz_models.dart';

abstract final class _PassiversatzLayout {
  static const EdgeInsetsDirectional pagePadding = EdgeInsetsDirectional.fromSTEB(
    16,
    16,
    16,
    32,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const double gapXs = 6;
  static const double gapS = 10;
  static const double gapM = 14;
  static const double gapL = 18;
  static const double icon = 28;
}

final class PassiversatzScreen extends StatefulWidget {
  const PassiversatzScreen({super.key});

  @override
  State<PassiversatzScreen> createState() => _PassiversatzScreenState();
}

final class _PassiversatzScreenState extends State<PassiversatzScreen> {
  static const PassiversatzEngine _engine = PassiversatzEngine();

  final TextEditingController _answerController = TextEditingController();
  int _challengeIndex = 0;
  PassiversatzForm? _selectedForm;
  PassiversatzEvaluation? _evaluation;

  PassiversatzChallenge get _challenge =>
      _engine.challengeAt(_challengeIndex);

  PassiversatzForm get _activeForm =>
      _selectedForm ?? _challenge.alternatives.first.form;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _selectForm(PassiversatzForm form) {
    setState(() {
      _selectedForm = form;
      _evaluation = null;
      _answerController.clear();
    });
  }

  void _checkAnswer() {
    if (_answerController.text.trim().isEmpty) return;
    setState(() {
      _evaluation = _engine.evaluate(
        challenge: _challenge,
        form: _activeForm,
        answer: _answerController.text,
      );
    });
  }

  void _nextChallenge() {
    setState(() {
      _challengeIndex = (_challengeIndex + 1) % _engine.challenges.length;
      _selectedForm = null;
      _evaluation = null;
      _answerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenge;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بدائل المبني للمجهول · Passiversatzformen'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: _PassiversatzLayout.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _IntroCard(
                  current: _challengeIndex + 1,
                  total: _engine.challenges.length,
                ),
                const SizedBox(height: _PassiversatzLayout.gapM),
                _ChallengeCard(challenge: challenge),
                const SizedBox(height: _PassiversatzLayout.gapM),
                _FormPicker(
                  challenge: challenge,
                  selected: _activeForm,
                  onSelected: _selectForm,
                ),
                const SizedBox(height: _PassiversatzLayout.gapM),
                _AnswerCard(
                  controller: _answerController,
                  selectedForm: _activeForm,
                  evaluation: _evaluation,
                  onChanged: () => setState(() {}),
                  onCheck: _checkAnswer,
                ),
                if (_evaluation != null) ...<Widget>[
                  const SizedBox(height: _PassiversatzLayout.gapM),
                  _FeedbackCard(
                    challenge: challenge,
                    evaluation: _evaluation!,
                  ),
                  const SizedBox(height: _PassiversatzLayout.gapM),
                  FilledButton.tonalIcon(
                    onPressed: _nextChallenge,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('التمرين التالي'),
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

final class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        padding: _PassiversatzLayout.cardPadding,
        borderColor: AppColors.primary.withAlpha(90),
        glowColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: _PassiversatzLayout.icon,
                ),
                const SizedBox(width: _PassiversatzLayout.gapS),
                Expanded(
                  child: Text(
                    'حوّل الـ Passiv إلى صياغة ألمانية بديلة',
                    style: AppTypography.title,
                  ),
                ),
                Text(
                  '$current / $total',
                  textDirection: TextDirection.ltr,
                  style: AppTypography.label.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _PassiversatzLayout.gapS),
            Text(
              'اختر البناء المطلوب، ثم اكتب الجملة كاملة. '
              'التقييم يتسامح مع المسافات وحالة الأحرف وعلامة النهاية فقط.',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final PassiversatzChallenge challenge;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        padding: _PassiversatzLayout.cardPadding,
        borderColor: AppColors.secondary.withAlpha(90),
        glowColor: AppColors.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Directionality(
              key: const ValueKey<String>('passiversatz-arabic-direction'),
              textDirection: TextDirection.rtl,
              child: Text(
                challenge.contextAr,
                style: AppTypography.label.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: _PassiversatzLayout.gapS),
            Text('Passiv', style: AppTypography.title),
            const SizedBox(height: _PassiversatzLayout.gapXs),
            Directionality(
              key: const ValueKey<String>('passiversatz-german-direction'),
              textDirection: TextDirection.ltr,
              child: Text(
                challenge.passiveSentence,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: _PassiversatzLayout.gapS),
            Text(challenge.ruleAr, style: AppTypography.body),
          ],
        ),
      );
}

final class _FormPicker extends StatelessWidget {
  const _FormPicker({
    required this.challenge,
    required this.selected,
    required this.onSelected,
  });

  final PassiversatzChallenge challenge;
  final PassiversatzForm selected;
  final ValueChanged<PassiversatzForm> onSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        padding: _PassiversatzLayout.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('اختر Passiversatzform', style: AppTypography.title),
            const SizedBox(height: _PassiversatzLayout.gapS),
            Wrap(
              spacing: _PassiversatzLayout.gapS,
              runSpacing: _PassiversatzLayout.gapS,
              children: <Widget>[
                for (final alternative in challenge.alternatives)
                  ChoiceChip(
                    label: Text(
                      alternative.form.germanLabel,
                      textDirection: TextDirection.ltr,
                    ),
                    selected: selected == alternative.form,
                    selectedColor: AppColors.primary.withAlpha(36),
                    side: BorderSide(
                      color: selected == alternative.form
                          ? AppColors.primary
                          : Theme.of(context).dividerColor,
                    ),
                    onSelected: (_) => onSelected(alternative.form),
                  ),
              ],
            ),
            const SizedBox(height: _PassiversatzLayout.gapS),
            Text(
              selected.arabicLabel,
              style: AppTypography.label.copyWith(
                color: AppColors.tertiary,
              ),
            ),
          ],
        ),
      );
}

final class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.controller,
    required this.selectedForm,
    required this.evaluation,
    required this.onChanged,
    required this.onCheck,
  });

  final TextEditingController controller;
  final PassiversatzForm selectedForm;
  final PassiversatzEvaluation? evaluation;
  final VoidCallback onChanged;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        padding: _PassiversatzLayout.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'اكتب التحويل',
              style: AppTypography.title,
            ),
            const SizedBox(height: _PassiversatzLayout.gapXs),
            Text(
              selectedForm.germanLabel,
              textDirection: TextDirection.ltr,
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: _PassiversatzLayout.gapS),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: controller,
                enabled: evaluation == null,
                textDirection: TextDirection.ltr,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  hintText: 'Deine Umformung …',
                ),
                onChanged: (_) => onChanged(),
                onSubmitted: (_) {
                  if (controller.text.trim().isNotEmpty && evaluation == null) {
                    onCheck();
                  }
                },
              ),
            ),
            const SizedBox(height: _PassiversatzLayout.gapM),
            FilledButton.icon(
              onPressed: controller.text.trim().isEmpty || evaluation != null
                  ? null
                  : onCheck,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('تحقق من التحويل'),
            ),
          ],
        ),
      );
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.challenge,
    required this.evaluation,
  });

  final PassiversatzChallenge challenge;
  final PassiversatzEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final alternative = challenge.alternativeFor(evaluation.form)!;
    final color = evaluation.isCorrect
        ? AppColors.mastery
        : Theme.of(context).colorScheme.error;

    return AppGlassCard(
      padding: _PassiversatzLayout.cardPadding,
      borderColor: color.withAlpha(120),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                evaluation.isCorrect
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                color: color,
              ),
              const SizedBox(width: _PassiversatzLayout.gapS),
              Expanded(
                child: Text(
                  evaluation.isCorrect
                      ? 'التحويل صحيح'
                      : 'الصياغة تحتاج تصحيحاً',
                  style: AppTypography.title.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: _PassiversatzLayout.gapS),
          Text(
            'الصياغة المعتمدة:',
            style: AppTypography.label,
          ),
          const SizedBox(height: _PassiversatzLayout.gapXs),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              evaluation.expected,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: _PassiversatzLayout.gapS),
          Text(alternative.noteAr, style: AppTypography.body),
        ],
      ),
    );
  }
}
