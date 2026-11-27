import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../features/audio/domain/entities/audio_request.dart';
import '../../models/content.dart';
import '../../models/learner.dart';
import '../../services/grammar_hub_service.dart';
import '../../services/app_dependencies.dart';
import '../../design_system/app_audio_button.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart';
import '../../features/grammar/data/ar_de_grammar_explain_why.dart';
import '../../features/grammar/data/local_grammar_drill_repository.dart';
import '../../features/grammar/domain/grammar_drill_models.dart';
import '../../features/grammar/presentation/screens/grammar_drill_screen.dart';
import 'grammar_topic_detail_page.dart';

class GrammarHubPage extends StatefulWidget {
  final AppDependencies<ContentItem> dependencies;
  final LearnerState? learnerState;

  const GrammarHubPage({
    Key? key,
    required this.dependencies,
    this.learnerState,
  }) : super(key: key);

  @override
  State<GrammarHubPage> createState() => _GrammarHubPageState();
}

class _GrammarHubPageState extends State<GrammarHubPage> {
  String _selectedLevel = 'A1';
  final List<String> _levels = <String>['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  List<GrammarTopic> _topics = <GrammarTopic>[];
  bool _isLoading = true;
  bool _isDrillRepositoryLoading = true;
  GrammarDrillRepository? _activeDrillRepository;

  @override
  void initState() {
    super.initState();
    unawaited(_loadTopics());
    unawaited(_loadDrillRepository());
  }

  Future<void> _loadTopics() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    final topics = await widget.dependencies.grammarHubService.getTopicsByLevel(
      _selectedLevel,
    );
    if (!mounted) return;
    setState(() {
      _topics = topics;
      _isLoading = false;
    });
  }

  void _onLevelSelected(String level) {
    if (_selectedLevel == level) return;
    setState(() => _selectedLevel = level);
    unawaited(_loadTopics());
  }

  GrammarLevel? get _drillLevel => switch (_selectedLevel) {
        'A1' => GrammarLevel.a1,
        'A2' => GrammarLevel.a2,
        'B1' => GrammarLevel.b1,
        _ => null,
      };

  Future<void> _loadDrillRepository() async {
    final sourceLocale = widget.dependencies.languagePack.sourceLocale;
    final targetLocale = widget.dependencies.languagePack.targetLocale;
    final source = sourceLocale.trim().toLowerCase().split(RegExp('[-_]')).first;
    final target = targetLocale.trim().toLowerCase().split(RegExp('[-_]')).first;

    if (source != 'ar' || target != 'de') {
      if (!mounted) return;
      setState(() {
        _activeDrillRepository = null;
        _isDrillRepositoryLoading = false;
      });
      return;
    }

    try {
      final explainWhyEngine = await ArDeGrammarExplainWhyCatalog.load(
        readText: rootBundle.loadString,
      );
      final repository = LocalGrammarDrillRepository.forDirectedPair(
        sourceLocale: sourceLocale,
        targetLocale: targetLocale,
        explainWhyEngine: explainWhyEngine,
      );
      if (!mounted) return;
      setState(() {
        _activeDrillRepository = repository;
        _isDrillRepositoryLoading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _activeDrillRepository = null;
        _isDrillRepositoryLoading = false;
      });
    }
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

  void _openInteractiveDrills() {
    final level = _drillLevel;
    final repository = _activeDrillRepository;
    if (level == null || repository == null) return;
    final exercises = repository.forLevel(level);
    if (exercises.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => GrammarDrillScreen(
          exercises: exercises,
          levelLabel: level.code,
          explainWhyEngine: repository.explainWhyEngine,
          errorDiagnosticSink: widget.dependencies.errorPatternAgent,
          targetLanguageCode: widget.dependencies.languagePack.targetLocale,
          onSpeakGerman: _speakGerman,
        ),
      ),
    );
  }

  double _glassOpacity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? .38 : .72;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: AppDirectionalText(
            'القواعد والتمارين',
            languageCode: 'ar',
            style: AppTypography.title,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: _levels.map((level) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: AppDirectionalText(
                        level,
                        languageCode: 'de',
                        style: AppTypography.label,
                      ),
                      selected: _selectedLevel == level,
                      onSelected: (_) => _onLevelSelected(level),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: AppGlassCard(
                backgroundColor: scheme.surface,
                opacity: _glassOpacity(context),
                glowColor: AppColors.primary,
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.extension_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AppDirectionalText(
                            'تدريب القواعد التفاعلي',
                            languageCode: 'ar',
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: 4),
                          AppDirectionalText(
                            _isDrillRepositoryLoading
                                ? 'جاري تجهيز شرح القواعد المحلي.'
                                : _activeDrillRepository == null
                                    ? 'لا توجد حزمة تمارين معتمدة لزوج اللغة النشط.'
                                    : _drillLevel == null
                                        ? 'بنك التمارين متاح حاليًا من A1 إلى B1.'
                                        : 'رتّب الجمل، صرّف الأفعال، وتدرّب على الحالات الإعرابية.',
                            languageCode: 'ar',
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _isDrillRepositoryLoading ||
                              _activeDrillRepository == null ||
                              _drillLevel == null
                          ? null
                          : _openInteractiveDrills,
                      child: AppDirectionalText(
                        'ابدأ',
                        languageCode: 'ar',
                        style: AppTypography.label,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _topics.isEmpty
                      ? Center(
                          child: AppDirectionalText(
                            'لا توجد مواضيع متاحة لهذا المستوى.',
                            languageCode: 'ar',
                            style: AppTypography.body,
                          ),
                        )
                      : ListView.separated(
                          // Performance: bound pre-build, disable keep-alives, isolate repaints.
                          // Expected lower jank and memory for off-screen grammar topic cards.
                          cacheExtent: 300,
                          addAutomaticKeepAlives: false,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                          itemCount: _topics.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final topic = _topics[index];
                            final accent = topic.isMastered
                                ? AppColors.mastery
                                : AppColors.primary;
                            return RepaintBoundary(
                              child: AppGlassCard(
                                onTap: () async {
                                  await Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          GrammarTopicDetailPage(
                                        topic: topic,
                                        dependencies: widget.dependencies,
                                        learnerState: widget.learnerState,
                                      ),
                                    ),
                                  );
                                  await _loadTopics();
                                },
                                backgroundColor: scheme.surface,
                                opacity: _glassOpacity(context),
                                borderColor: accent.withAlpha(120),
                                glowColor: topic.isMastered ? accent : null,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          AppDirectionalText(
                                            topic.titleDe,
                                            languageCode: 'de',
                                            style: AppTypography.title,
                                          ),
                                          const SizedBox(height: 4),
                                          AppDirectionalText(
                                            topic.titleAr,
                                            languageCode: 'ar',
                                            style: AppTypography.body,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AppAudioButton(
                                      onPressed: () => _speakGerman(
                                        topic.titleDe,
                                        'grammar.topic.${topic.id}',
                                      ),
                                      semanticLabel:
                                          'استمع إلى ${topic.titleDe}',
                                      activeColor: accent,
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      topic.isMastered
                                          ? Icons.check_circle_rounded
                                          : Icons.chevron_left_rounded,
                                      color: accent,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
