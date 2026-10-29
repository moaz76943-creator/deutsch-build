import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/audio/domain/entities/audio_request.dart';
import '../../models/content.dart';
import '../../models/learner.dart';
import '../../services/grammar_hub_service.dart';
import '../../services/app_dependencies.dart';
import '../../design_system/app_audio_button.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart';
import 'grammar_microscope_page.dart';
import 'grammar_quiz_page.dart';

class GrammarTopicDetailPage extends StatelessWidget {
  final GrammarTopic topic;
  final AppDependencies<ContentItem> dependencies;
  final LearnerState? learnerState;

  const GrammarTopicDetailPage({
    Key? key,
    required this.topic,
    required this.dependencies,
    this.learnerState,
  }) : super(key: key);

  void _speakGerman(String text, String conceptId) {
    final value = text.trim();
    if (value.isEmpty) return;
    unawaited(
      dependencies.audioRuntime
          .play(
            AudioRequest(
              text: value,
              languageCode: dependencies.languagePack.targetLocale,
              conceptId: conceptId,
              variant: AudioVariant.sentence,
            ),
          )
          .then<void>((_) {}),
    );
  }

  double _glassOpacity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? .38 : .72;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formula = topic.formulaPattern?.trim() ?? '';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: AppDirectionalText(
            topic.titleDe,
            languageCode: 'de',
            style: AppTypography.title,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppGlassCard(
                backgroundColor: scheme.surface,
                opacity: _glassOpacity(context),
                glowColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      topic.titleAr,
                      languageCode: 'ar',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: 6),
                    AppDirectionalText(
                      topic.titleDe,
                      languageCode: 'de',
                      style: AppTypography.body.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (formula.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                AppGlassCard(
                  backgroundColor: scheme.surface,
                  opacity: _glassOpacity(context),
                  glowColor: AppColors.tertiary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppDirectionalText(
                        'القاعدة (الصيغة)',
                        languageCode: 'ar',
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AppDirectionalText(
                              formula,
                              languageCode: 'de',
                              style: AppTypography.title,
                            ),
                          ),
                          const SizedBox(width: 10),
                          AppAudioButton(
                            onPressed: () => _speakGerman(
                              formula,
                              'grammar.formula.${topic.id}',
                            ),
                            semanticLabel: 'استمع إلى صيغة القاعدة',
                            activeColor: AppColors.tertiary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AppGlassCard(
                backgroundColor: scheme.surface,
                opacity: _glassOpacity(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDirectionalText(
                      'الشرح',
                      languageCode: 'ar',
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 8),
                    AppDirectionalText(
                      topic.explanationMarkdown,
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ),
              if (learnerState != null) ...<Widget>[
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => GrammarMicroscopePage(
                          topicId: topic.id,
                          state: learnerState!,
                          dependencies: dependencies,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.biotech_outlined),
                  label: AppDirectionalText(
                    'مجهر القواعد',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => GrammarQuizPage(
                        topicId: topic.id,
                        dependencies: dependencies,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.quiz_outlined),
                label: AppDirectionalText(
                  'ابدأ الاختبار القصير',
                  languageCode: 'ar',
                  style: AppTypography.label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
