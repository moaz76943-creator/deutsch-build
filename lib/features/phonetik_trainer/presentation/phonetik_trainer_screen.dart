import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../application/phonetik_engine.dart';
import '../domain/phonetik_models.dart';

abstract final class _PhonetikUiTokens {
  static const double pageInset = 16;
  static const double sectionGap = 14;
  static const double contentGap = 10;
  static const double chipGap = 8;
  static const double bottomInset = 32;
}

final class PhonetikTrainerScreen extends StatefulWidget {
  PhonetikTrainerScreen({
    PhonetikTrainerEngine? engine,
    super.key,
  }) : engine = engine ?? PhonetikTrainerEngine.standard();

  final PhonetikTrainerEngine engine;

  @override
  State<PhonetikTrainerScreen> createState() => _PhonetikTrainerScreenState();
}

final class _PhonetikTrainerScreenState extends State<PhonetikTrainerScreen> {
  final Map<String, String> _selectedChoices = <String, String>{};
  final Map<String, PhonetikAnswerResult> _results =
      <String, PhonetikAnswerResult>{};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: Text(
            'مدرب النطق الألماني',
            style: AppTypography.title,
            textDirection: TextDirection.rtl,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              _PhonetikUiTokens.pageInset,
              _PhonetikUiTokens.pageInset,
              _PhonetikUiTokens.pageInset,
              _PhonetikUiTokens.bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _IntroCard(),
                const SizedBox(height: _PhonetikUiTokens.sectionGap),
                for (var index = 0;
                    index < widget.engine.focuses.length;
                    index++) ...<Widget>[
                  _FocusCard(
                    focus: widget.engine.focuses[index],
                    selectedChoice:
                        _selectedChoices[widget.engine.focuses[index].id],
                    result: _results[widget.engine.focuses[index].id],
                    onChoiceSelected: (choice) {
                      final focus = widget.engine.focuses[index];
                      setState(() {
                        _selectedChoices[focus.id] = choice;
                        _results[focus.id] = widget.engine.evaluate(
                          focusId: focus.id,
                          selectedChoice: choice,
                        );
                      });
                    },
                  ),
                  if (index != widget.engine.focuses.length - 1)
                    const SizedBox(height: _PhonetikUiTokens.sectionGap),
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
  const _IntroCard();

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: AppColors.primary,
        borderColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              'Phonetik & Aussprache',
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _PhonetikUiTokens.contentGap),
            AppDirectionalText(
              'تدريب مركز على موضع اللسان والشفتين والاحتكاك والنبر. اقرأ المثال ببطء ثم أعده بإيقاع طبيعي.',
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}

final class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.focus,
    required this.onChoiceSelected,
    this.selectedChoice,
    this.result,
  });

  final PhonetikFocus focus;
  final String? selectedChoice;
  final PhonetikAnswerResult? result;
  final ValueChanged<String> onChoiceSelected;

  @override
  Widget build(BuildContext context) => AppGlassCard(
        glowColor: _accentFor(focus.topic),
        borderColor: _accentFor(focus.topic),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              focus.titleDe,
              languageCode: 'de',
              style: AppTypography.title,
            ),
            const SizedBox(height: _PhonetikUiTokens.chipGap),
            AppDirectionalText(
              focus.titleAr,
              languageCode: 'ar',
              style: AppTypography.label.copyWith(
                color: _accentFor(focus.topic),
              ),
            ),
            const SizedBox(height: _PhonetikUiTokens.contentGap),
            AppDirectionalText(
              focus.articulationAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
            const Divider(),
            for (final example in focus.examples)
              _ExampleTile(example: example),
            const Divider(),
            AppDirectionalText(
              focus.exercise.promptAr,
              languageCode: 'ar',
              style: AppTypography.label,
            ),
            const SizedBox(height: _PhonetikUiTokens.chipGap),
            Wrap(
              spacing: _PhonetikUiTokens.chipGap,
              runSpacing: _PhonetikUiTokens.chipGap,
              children: <Widget>[
                for (final choice in focus.exercise.choices)
                  ChoiceChip(
                    label: AppDirectionalText(
                      choice,
                      languageCode: _choiceLanguageCode(choice),
                      style: AppTypography.label,
                    ),
                    selected: selectedChoice == choice,
                    selectedColor: _accentFor(focus.topic),
                    onSelected: (_) => onChoiceSelected(choice),
                  ),
              ],
            ),
            if (result != null) ...<Widget>[
              const SizedBox(height: _PhonetikUiTokens.contentGap),
              AppDirectionalText(
                result!.feedbackAr,
                languageCode: 'ar',
                style: AppTypography.body.copyWith(
                  color: result!.isCorrect
                      ? AppColors.mastery
                      : AppColors.tertiary,
                ),
              ),
            ],
          ],
        ),
      );

  static Color _accentFor(PhonetikTopic topic) => switch (topic) {
        PhonetikTopic.ichAch => AppColors.primary,
        PhonetikTopic.umlautA => AppColors.articleDie,
        PhonetikTopic.umlautO => AppColors.secondary,
        PhonetikTopic.umlautU => AppColors.articleDer,
        PhonetikTopic.spSt => AppColors.tertiary,
        PhonetikTopic.stressIntonation => AppColors.achievement,
      };

  static String _choiceLanguageCode(String choice) {
    final hasArabic =
        choice.runes.any((rune) => rune >= 0x0600 && rune <= 0x06FF);
    return hasArabic ? 'ar' : 'de';
  }
}

final class _ExampleTile extends StatelessWidget {
  const _ExampleTile({required this.example});

  final PhonetikExample example;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: AppDirectionalText(
          example.word,
          languageCode: 'de',
          style: AppTypography.title,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDirectionalText(
              example.ipa,
              languageCode: 'de',
              style: AppTypography.label,
            ),
            AppDirectionalText(
              example.hintAr,
              languageCode: 'ar',
              style: AppTypography.body,
            ),
          ],
        ),
      );
}
