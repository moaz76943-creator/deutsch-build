import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/clause_connector_notifier.dart';
import '../domain/clause_connector_models.dart';

final class ClauseConnectorScreen extends StatefulWidget {
  const ClauseConnectorScreen({
    required this.notifier,
    super.key,
  });

  final ClauseConnectorNotifier notifier;

  @override
  State<ClauseConnectorScreen> createState() =>
      _ClauseConnectorScreenState();
}

final class _ClauseConnectorScreenState
    extends State<ClauseConnectorScreen> {
  String? _selectedConnector;
  String? _selectedVerbPosition;

  ClauseConnectorNotifier get notifier => widget.notifier;

  @override
  void initState() {
    super.initState();
    notifier.addListener(_refresh);
    if (notifier.currentChallenge == null) {
      unawaited(notifier.nextChallenge());
    }
  }

  @override
  void didUpdateWidget(covariant ClauseConnectorScreen oldWidget) {
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

  Future<void> _nextChallenge() async {
    setState(() {
      _selectedConnector = null;
      _selectedVerbPosition = null;
    });
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
          title: Text('وكيل أدوات الربط', style: AppTypography.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          top: false,
          child: challenge == null
              ? _EmptyOrLoadingState(
                  isBusy: notifier.isBusy,
                  message: notifier.feedbackExplanation,
                  onRetry: () => unawaited(notifier.nextChallenge()),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  children: <Widget>[
                    _ChallengeHeader(
                      challenge: challenge,
                      dark: dark,
                    ),
                    const SizedBox(height: 12),
                    _SentencePairCard(
                      challenge: challenge,
                      dark: dark,
                    ),
                    const SizedBox(height: 14),
                    const _SectionTitle(
                      title: '1. اختر أداة الربط',
                      subtitle:
                          'قارن بين معنى الأداة وتأثيرها على ترتيب الفعل.',
                    ),
                    const SizedBox(height: 8),
                    _ConnectorOptions(
                      options: notifier.options,
                      selected: _selectedConnector,
                      enabled: !notifier.isBusy,
                      onSelected: (value) {
                        setState(() => _selectedConnector = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    const _SectionTitle(
                      title: '2. حدّد موقع الفعل',
                      subtitle:
                          'راقب كيف يتغيّر ترتيب الجملة بعد أداة الربط.',
                    ),
                    const SizedBox(height: 8),
                    _VerbKickerVisualizer(
                      selectedPosition: _selectedVerbPosition,
                      enabled: !notifier.isBusy,
                      onSelected: (value) {
                        setState(() => _selectedVerbPosition = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _SubmitCard(
                      enabled: _selectedConnector != null &&
                          _selectedVerbPosition != null &&
                          !notifier.isBusy,
                      onSubmit: () => unawaited(
                        notifier.submitConnector(
                          _selectedConnector!,
                          _selectedVerbPosition!,
                        ),
                      ),
                    ),
                    if (notifier.isCorrect != null) ...<Widget>[
                      const SizedBox(height: 14),
                      _FeedbackCard(
                        correct: notifier.isCorrect!,
                        explanation:
                            notifier.feedbackExplanation ?? '',
                        correctSentence:
                            challenge.correctCombinedSentence,
                      ),
                      const SizedBox(height: 12),
                      AppGlassCard(
                        onTap: notifier.isBusy
                            ? null
                            : () => unawaited(_nextChallenge()),
                        glowColor: AppColors.primary,
                        borderColor: AppColors.primary.withAlpha(82),
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

final class _ChallengeHeader extends StatelessWidget {
  const _ChallengeHeader({
    required this.challenge,
    required this.dark,
  });

  final ConnectorChallengeItem challenge;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (challenge.type) {
      ConjunctionType.positionZero => (
          'Position 0',
          AppColors.secondary,
        ),
      ConjunctionType.verbKicker => (
          'Verb-Kicker',
          AppColors.tertiary,
        ),
      ConjunctionType.adverbialConnector => (
          'Adverbial Connector',
          AppColors.primary,
        ),
    };

    return AppGlassCard(
      glowColor: color,
      borderColor: color.withAlpha(76),
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Row(
        children: <Widget>[
          Icon(Icons.account_tree_rounded, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'اربط الجملتين',
                  style: AppTypography.title.copyWith(
                    color: dark ? Colors.white : AppColors.darkSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: AppTypography.label.copyWith(color: color),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _SentencePairCard extends StatelessWidget {
  const _SentencePairCard({
    required this.challenge,
    required this.dark,
  });

  final ConnectorChallengeItem challenge;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      glowColor: AppColors.primary,
      borderColor:
          dark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
      backgroundColor:
          dark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SentenceLine(
            number: '1',
            sentence: challenge.firstSentence,
          ),
          const SizedBox(height: 10),
          const Icon(
            Icons.add_link_rounded,
            color: AppColors.primary,
            size: 30,
          ),
          const SizedBox(height: 10),
          _SentenceLine(
            number: '2',
            sentence: challenge.secondSentence,
          ),
        ],
      ),
    );
  }
}

final class _SentenceLine extends StatelessWidget {
  const _SentenceLine({
    required this.number,
    required this.sentence,
  });

  final String number;
  final String sentence;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withAlpha(24),
          ),
          child: Text(
            number,
            style: AppTypography.label.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppDirectionalText(
            sentence,
            languageCode: 'de',
            style: AppTypography.title,
          ),
        ),
      ],
    );
  }
}

final class _ConnectorOptions extends StatelessWidget {
  const _ConnectorOptions({
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
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final option in options)
          SizedBox(
            width: 150,
            child: AppGlassCard(
              onTap: enabled ? () => onSelected(option) : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              borderColor: selected == option
                  ? AppColors.primary
                  : AppColors.primary.withAlpha(52),
              glowColor:
                  selected == option ? AppColors.primary : null,
              child: Center(
                child: Text(
                  option,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.title.copyWith(
                    color: selected == option
                        ? AppColors.primary
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

final class _VerbKickerVisualizer extends StatelessWidget {
  const _VerbKickerVisualizer({
    required this.selectedPosition,
    required this.enabled,
    required this.onSelected,
  });

  final String? selectedPosition;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _VerbPositionChoice(
          value: ClauseConnectorNotifier.verbSecondPosition,
          selected: selectedPosition,
          enabled: enabled,
          title: 'Position 0 → V2',
          explanation: 'denn + Subjekt + VERB + Rest',
          tokens: const <String>[
            'denn',
            'Subjekt',
            'VERB · 2',
            'Rest',
          ],
          accent: AppColors.secondary,
          onSelected: onSelected,
        ),
        const SizedBox(height: 9),
        _VerbPositionChoice(
          value: ClauseConnectorNotifier.verbFinalPosition,
          selected: selectedPosition,
          enabled: enabled,
          title: 'Verb-Kicker → الفعل للنهاية',
          explanation: 'weil / obwohl / dass + … + VERB',
          tokens: const <String>[
            'weil',
            'Subjekt',
            'Mittelfeld',
            'VERB ↓ Ende',
          ],
          accent: AppColors.tertiary,
          onSelected: onSelected,
        ),
        const SizedBox(height: 9),
        _VerbPositionChoice(
          value:
              ClauseConnectorNotifier.inversionVerbSecondPosition,
          selected: selectedPosition,
          enabled: enabled,
          title: 'Adverbial → Inversion',
          explanation: 'deshalb + VERB + Subjekt + Rest',
          tokens: const <String>[
            'deshalb',
            'VERB · 2',
            'Subjekt',
            'Rest',
          ],
          accent: AppColors.primary,
          onSelected: onSelected,
        ),
      ],
    );
  }
}

final class _VerbPositionChoice extends StatelessWidget {
  const _VerbPositionChoice({
    required this.value,
    required this.selected,
    required this.enabled,
    required this.title,
    required this.explanation,
    required this.tokens,
    required this.accent,
    required this.onSelected,
  });

  final String value;
  final String? selected;
  final bool enabled;
  final String title;
  final String explanation;
  final List<String> tokens;
  final Color accent;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return AppGlassCard(
      onTap: enabled ? () => onSelected(value) : null,
      borderColor:
          isSelected ? accent : accent.withAlpha(56),
      glowColor: isSelected ? accent : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: isSelected ? accent : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            textDirection: TextDirection.ltr,
            style: AppTypography.label,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            textDirection: TextDirection.ltr,
            children: <Widget>[
              for (final token in tokens)
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: token.contains('VERB')
                        ? accent.withAlpha(30)
                        : AppColors.primary.withAlpha(12),
                    border: Border.all(
                      color: token.contains('VERB')
                          ? accent.withAlpha(100)
                          : AppColors.primary.withAlpha(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(
                      token,
                      style: AppTypography.label.copyWith(
                        color:
                            token.contains('VERB') ? accent : null,
                      ),
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

final class _SubmitCard extends StatelessWidget {
  const _SubmitCard({
    required this.enabled,
    required this.onSubmit,
  });

  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      onTap: enabled ? onSubmit : null,
      glowColor: enabled ? AppColors.mastery : null,
      borderColor: enabled
          ? AppColors.mastery.withAlpha(100)
          : AppColors.primary.withAlpha(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check_circle_rounded,
            color: enabled
                ? AppColors.mastery
                : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            'تحقق من الربط',
            style: AppTypography.title.copyWith(
              color: enabled
                  ? AppColors.mastery
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

final class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.correct,
    required this.explanation,
    required this.correctSentence,
  });

  final bool correct;
  final String explanation;
  final String correctSentence;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.mastery : AppColors.tertiary;
    return AppGlassCard(
      glowColor: color,
      borderColor: color.withAlpha(88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : Icons.lightbulb_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correct ? 'صحيح' : 'راجع موقع الفعل',
                  style: AppTypography.title.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppDirectionalText(
            explanation,
            languageCode: 'ar',
          ),
          const SizedBox(height: 10),
          AppDirectionalText(
            correctSentence,
            languageCode: 'de',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: AppTypography.title),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTypography.body),
      ],
    );
  }
}

final class _EmptyOrLoadingState extends StatelessWidget {
  const _EmptyOrLoadingState({
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
                Icons.link_off_rounded,
                color: AppColors.tertiary,
                size: 36,
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
