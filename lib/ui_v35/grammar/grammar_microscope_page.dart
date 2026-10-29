import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/text/directional_text.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart';
import '../../features/audio/domain/entities/audio_request.dart';
import '../../models/content.dart';
import '../../models/learner.dart';
import '../../services/app_dependencies.dart';
import '../../services/grammar_microscope_service.dart';
import '../shared/text/bidi_text.dart';
import 'grammar_microscope_sections.dart';

class GrammarMicroscopePage extends StatefulWidget {
  const GrammarMicroscopePage({
    super.key,
    required this.topicId,
    required this.state,
    required this.dependencies,
  });

  final String topicId;
  final LearnerState state;
  final AppDependencies<ContentItem> dependencies;

  @override
  State<GrammarMicroscopePage> createState() => _GrammarMicroscopePageState();
}

class _GrammarMicroscopePageState extends State<GrammarMicroscopePage> {
  late final Future<GrammarMicroscopeSnapshot?> _snapshot;

  @override
  void initState() {
    super.initState();
    _snapshot =
        GrammarMicroscopeService(widget.dependencies.grammarHubService).load(
      topicId: widget.topicId,
      state: widget.state,
      corpus: widget.dependencies.corpus,
    );
  }

  void _speakGerman(String text, String conceptId) {
    final value = text.trim();
    if (value.isEmpty) return;
    unawaited(
      widget.dependencies.audioRuntime
          .play(
            AudioRequest(
              text: value,
              languageCode: widget.dependencies.languagePack.targetLocale,
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
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: AppDirectionalText(
              'مجهر القواعد',
              languageCode: 'ar',
              style: AppTypography.title,
            ),
          ),
          body: FutureBuilder<GrammarMicroscopeSnapshot?>(
            future: _snapshot,
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (asyncSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppDirectionalText(
                      'تعذر تحميل تفاصيل القاعدة بأمان.',
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ),
                );
              }

              final snapshot = asyncSnapshot.data;
              if (snapshot == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppDirectionalText(
                      'موضوع القاعدة غير متاح في المصدر النشط.',
                      languageCode: 'ar',
                      style: AppTypography.body,
                    ),
                  ),
                );
              }

              final scheme = Theme.of(context).colorScheme;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: <Widget>[
                  AppGlassCard(
                    backgroundColor: scheme.surface,
                    opacity: _glassOpacity(context),
                    glowColor: AppColors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        BidiText(
                          DirectionalText.german(
                            snapshot.topic.titleDe,
                            semanticRole:
                                LinguisticSemanticRole.grammarLabel,
                          ),
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: 4),
                        BidiText(
                          DirectionalText.arabic(
                            snapshot.topic.titleAr,
                            semanticRole:
                                LinguisticSemanticRole.translation,
                          ),
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: 12),
                        BidiText(
                          DirectionalText.arabic(
                            snapshot.topic.explanationMarkdown,
                            semanticRole:
                                LinguisticSemanticRole.explanation,
                          ),
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GrammarMicroscopeEvidenceSection(snapshot: snapshot),
                  const SizedBox(height: 20),
                  GrammarMicroscopeRulesSection(
                    snapshot: snapshot,
                    onSpeakGerman: _speakGerman,
                  ),
                ],
              );
            },
          ),
        ),
      );
}
