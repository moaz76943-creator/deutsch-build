import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/content_contract.dart';
import '../../core/explainer/explainer.dart';
import '../../core/quick_review/quick_review.dart';
import '../../core/curriculum/advanced_vocabulary.dart';
import '../../core/curriculum/canonical_curriculum_50.dart';
import '../../core/curriculum/curriculum_models.dart';
import '../../core/design/flashcards_3d/flashcard_3d_models.dart';
import '../../features/audio/domain/services/i_audio_runtime.dart';
import '../../features/audio/hybrid_pronunciation_service.dart';
import '../../features/daily_drill/data/universal_session_drill_review_sink.dart';
import '../../features/daily_drill/domain/daily_drill_repository.dart';
import '../../design_system/app_glass_card.dart';
import '../../design_system/app_typography.dart';
import '../../features/gamification/gamification_repository.dart';
import '../../features/quick_review/presentation/srs_review_hub_screen.dart';
import '../../features/session/universal_session_orchestrator.dart';
import '../../services/repository.dart';
import '../../features/phase3_integration/life_curriculum_catalog.dart';
import '../../features/phase3_integration/production_agent_runtime.dart';
import 'language_selection_screen.dart';
import 'life_task_route_registry.dart';
import 'phase3_flashcards.dart';
import 'phase10_presentation_bridge.dart';
import 'phase10_tasks_track.dart';
import 'phase6_l10n_controller.dart';

final class Phase3ProductionShell extends StatefulWidget {
  const Phase3ProductionShell({
    required this.corpus,
    required this.audioRuntime,
    required this.learnerRepository,
    required this.gamificationRepository,
    required this.quickReviewService,
    required this.explainerService,
    required this.reviewSourceLanguageCode,
    required this.reviewTranslationLanguageCode,
    this.routeRegistry,
    this.localizationController,
    this.deckId = 'main-vocabulary',
    this.startTaskOrder = 1,
    super.key,
  }) : assert(startTaskOrder >= 1 && startTaskOrder <= 50);

  final List<LearningContent> corpus;
  final IAudioRuntime audioRuntime;
  final LearnerRepository learnerRepository;
  final GamificationRepository gamificationRepository;
  final QuickReviewService quickReviewService;
  final ExplainerService explainerService;
  final String reviewSourceLanguageCode;
  final String reviewTranslationLanguageCode;
  final LifeTaskRouteRegistry? routeRegistry;
  final Phase6L10nController? localizationController;
  final String deckId;
  final int startTaskOrder;

  @override
  State<Phase3ProductionShell> createState() =>
      _Phase3ProductionShellState();
}

final class _Phase3ProductionShellState extends State<Phase3ProductionShell> {
  late final Phase6L10nController _l10n;
  late final bool _ownsL10n;
  late final LifeTaskRouteRegistry _routes;
  late final LifeCurriculumCatalog _catalog;
  late final List<VocabularyFlashcardProjection> _projections;
  late final Phase3AgentRuntime _runtime;
  late final HybridPronunciationService _pronunciationAudio;
  late final UniversalSessionOrchestrator _quickReviewOrchestrator;
  late final DailyDrillReviewSink _quickReviewSink;
  late final Future<Phase10PresentationBridge> _phase10BridgeFuture;
  late final List<CurriculumTask> _routedTasks;

  Phase3DesignProfile? _design;
  int _index = 0;
  bool _busy = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _ownsL10n = widget.localizationController == null;
    _l10n = widget.localizationController ?? Phase6L10nController.standard();
    _routes = widget.routeRegistry ??
        LifeTaskRouteRegistry(localizationController: _l10n);
    _catalog = _routes.catalog;
    final routableTaskIds = _catalog.links
        .map((link) => link.curriculumTaskId)
        .toSet();
    _routedTasks = List<CurriculumTask>.unmodifiable(
      CanonicalCurriculum50.tasks.where(
        (task) =>
            task.order >= widget.startTaskOrder &&
            routableTaskIds.contains(task.id),
      ),
    );
    if (_routedTasks.isEmpty) {
      throw StateError(
        'No routable curriculum task exists at or after '
        'startTaskOrder=${widget.startTaskOrder}.',
      );
    }
    _index = widget.startTaskOrder > 1 ? 1 : 0;
    _projections = VocabularyProjectionFactory.fromContentList(widget.corpus);
    _runtime = Phase3AgentRuntime.start(
      catalog: _catalog,
      decks: VocabularyProjectionDeckRegistry(
        <String, List<VocabularyFlashcardProjection>>{
          widget.deckId: _projections,
        },
      ),
    );
    _pronunciationAudio = HybridPronunciationService(
      audioRuntime: widget.audioRuntime,
    );
    _quickReviewOrchestrator = UniversalSessionOrchestrator(
      repository: widget.learnerRepository,
    );
    _quickReviewSink = UniversalSessionDrillReviewSink(
      orchestrator: _quickReviewOrchestrator,
      gamificationRepository: widget.gamificationRepository,
    );
    _phase10BridgeFuture = Phase10PresentationBridge.start();
    unawaited(_loadDesign());
  }

  @override
  void dispose() {
    _quickReviewOrchestrator.dispose();
    unawaited(_runtime.close());
    unawaited(
      _phase10BridgeFuture
          .then((bridge) => bridge.close())
          .catchError((_) {}),
    );
    if (_ownsL10n) {
      _l10n.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDesign() async {
    try {
      final design = await _runtime.requestDesign();
      if (!mounted) return;
      setState(() => _design = design);
    } on Object catch (error) {
      _setError('error.design', error);
    }
  }

  Future<void> _openLifeTask(LifeCurriculumLink link) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _lastError = null;
    });
    try {
      final route = await _runtime.requestRoute(link.featureKey);
      if (!mounted) return;
      final builder = _routes.builderFor(route.featureKey);
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: builder),
      );
    } on Object catch (error) {
      _setError('error.task', error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openCards() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _lastError = null;
    });
    try {
      final ready = await _runtime.requestCards(widget.deckId);
      final presentationBridge = await _phase10BridgeFuture;
      if (!mounted) return;
      if (ready.cardCount != _projections.length) {
        throw StateError('Card deck count mismatch.');
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => Directionality(
            textDirection: _l10n.textDirection,
            child: Phase3FlashcardDeckPage(
              title: _l10n.text('cards.title'),
              emptyText: _l10n.text('cards.empty'),
              projections: _projections,
              presentationBridge: presentationBridge,
              onAudio: (card, face) {
                final language = face == Flashcard3DFace.front
                    ? card.frontLanguageCode
                    : card.backLanguageCode;
                final targetLanguage = _l10n
                    .snapshot.targetLocale.languageCode
                    .toLowerCase()
                    .split(RegExp('[-_]'))
                    .first;
                final cardLanguage = language
                    .toLowerCase()
                    .split(RegExp('[-_]'))
                    .first;
                if (targetLanguage != cardLanguage) return;
                final text = face == Flashcard3DFace.front
                    ? card.frontText
                    : card.backText;
                unawaited(
                  _pronunciationAudio.play(
                    conceptId: card.id,
                    text: text,
                    languageCode: language,
                  ),
                );
              },
            ),
          ),
        ),
      );
    } on Object catch (error) {
      _setError('error.cards', error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openQuickReview() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _lastError = null;
    });
    try {
      final learner = await widget.learnerRepository.reloadPersisted();
      final session = await widget.quickReviewService.buildSession(
        reviewCards: learner.reviewCards.values,
        now: DateTime.now(),
      );
      if (!mounted) return;
      _quickReviewOrchestrator.resetSession();
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => SrsReviewHubScreen(
            session: session,
            reviewSink: _quickReviewSink,
            pronunciationAudio: _pronunciationAudio,
            explainerService: widget.explainerService,
            sourceLanguageCode: widget.reviewSourceLanguageCode,
            translationLanguageCode: widget.reviewTranslationLanguageCode,
          ),
        ),
      );
    } on Object catch (error) {
      _setError('error.cards', error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openLanguageSelection() => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => LanguageSelectionScreen(controller: _l10n),
        ),
      );

  void _setError(String key, Object error) {
    if (!mounted) return;
    final message = _l10n.text(
      key,
      arguments: <String, Object?>{'error': error.toString()},
    );
    setState(() => _lastError = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _l10n,
        builder: (context, _) {
          final tabs = <Widget>[
            _overviewTab(context),
            _curriculumTab(context),
            _lifeTab(context),
            _cardsTab(context),
          ];

          return Directionality(
            textDirection: _l10n.textDirection,
            child: Scaffold(
              appBar: AppBar(
                title: Text(_titleForIndex(_index)),
                actions: <Widget>[
                  IconButton(
                    tooltip: _l10n.text('action.languages'),
                    onPressed: _openLanguageSelection,
                    icon: const Icon(Icons.translate_rounded),
                  ),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 16),
                      child: Center(
                        child: SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
              body: IndexedStack(
                index: _index,
                children: tabs,
              ),
              bottomNavigationBar:
                  _design == null || _design!.navigation == 'bottom'
                      ? NavigationBar(
                          selectedIndex: _index,
                          onDestinationSelected: (value) =>
                              setState(() => _index = value),
                          destinations: <NavigationDestination>[
                            NavigationDestination(
                              icon: const Icon(Icons.home_outlined),
                              selectedIcon:
                                  const Icon(Icons.home_rounded),
                              label: _l10n.text('nav.home'),
                            ),
                            NavigationDestination(
                              icon: const Icon(Icons.route_outlined),
                              selectedIcon:
                                  const Icon(Icons.route_rounded),
                              label: _l10n.text('nav.curriculum'),
                            ),
                            NavigationDestination(
                              icon: const Icon(Icons.apps_outlined),
                              selectedIcon:
                                  const Icon(Icons.apps_rounded),
                              label: _l10n.text('nav.life'),
                            ),
                            NavigationDestination(
                              icon: const Icon(Icons.view_in_ar_outlined),
                              selectedIcon:
                                  const Icon(Icons.view_in_ar_rounded),
                              label: _l10n.text('nav.cards'),
                            ),
                          ],
                        )
                      : null,
            ),
          );
        },
      );

  Widget _overviewTab(BuildContext context) {
    final design = _design;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _StatusCard(
          icon: Icons.architecture_outlined,
          title: _l10n.text('status.integration.title'),
          value: design == null
              ? _l10n.text('status.loading')
              : _l10n.text('status.active'),
          detail: design == null
              ? _l10n.text('status.integration.loading')
              : _l10n.text(
                  'status.integration.detail',
                  arguments: <String, Object?>{
                    'navigation': design.navigation,
                    'cards': design.flashcardMode,
                    'direction': _l10n.snapshot.direction.toUpperCase(),
                  },
                ),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          icon: Icons.translate_rounded,
          title: _l10n.text('action.languages'),
          value: _l10n.text(
            'language.matrix',
            arguments: <String, Object?>{
              'source': _l10n.languageLabel(_l10n.pair.source.id),
              'target': _l10n.languageLabel(_l10n.pair.target.id),
            },
          ),
          detail: _l10n.text(
            'language.directions',
            arguments: <String, Object?>{
              'count': _l10n.matrix.directedPairCount,
              'languages': _l10n.matrix.languages.length,
            },
          ),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          icon: Icons.checklist_rounded,
          title: _l10n.text('status.life.title'),
          value: _l10n.text(
            'status.life.value',
            arguments: <String, Object?>{
              'count': _catalog.links.length,
              'total': _catalog.links.length,
            },
          ),
          detail: _l10n.text('status.life.detail'),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          icon: Icons.menu_book_outlined,
          title: _l10n.text('status.curriculum.title'),
          value: _l10n.text(
            'status.curriculum.value',
            arguments: <String, Object?>{
              'count': _l10n.curriculumPlan.tasks.length,
            },
          ),
          detail: _l10n.text('status.curriculum.detail'),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          icon: Icons.view_in_ar_rounded,
          title: _l10n.text('status.cards.title'),
          value: _l10n.text(
            'status.cards.value',
            arguments: <String, Object?>{'count': _projections.length},
          ),
          detail: _l10n.text('status.cards.detail'),
        ),
        if (_lastError != null) ...<Widget>[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                _lastError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _curriculumTab(BuildContext context) =>
      FutureBuilder<Phase10PresentationBridge>(
        future: _phase10BridgeFuture,
        builder: (context, snapshot) {
          final bridge = snapshot.data;
          if (bridge == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Phase10TasksTrackView(
            initialSnapshot: bridge.progressSnapshot,
            progressStream: bridge.progressStream,
            fallbackSourceLanguageTag: _l10n.pair.source.id,
            fallbackTargetLanguageTag: _l10n.pair.target.id,
            tasks: _routedTasks,
            onTaskTap: _openCurriculumTask,
          );
        },
      );

  void _openCurriculumTask(CurriculumTask task) {
    final links = _catalog.links
        .where((link) => link.curriculumTaskId == task.id)
        .toList(growable: false);
    if (links.isEmpty || _busy) return;
    unawaited(_openLifeTask(links.first));
  }

  Widget _lifeTab(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: _catalog.links.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final link = _catalog.links[index];
          final directed = _l10n.curriculumPlan
              .taskByCanonicalId(link.curriculumTaskId);
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${link.ordinal}')),
              title: Text(_lifeTitle(link)),
              subtitle: Text(
                _l10n.text(
                  'life.linked_lesson',
                  arguments: <String, Object?>{
                    'order': directed.task.order,
                    'title': _taskTitle(directed.task),
                  },
                ),
              ),
              trailing:
                  const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: _busy ? null : () => _openLifeTask(link),
            ),
          );
        },
      );

  Widget _cardsTab(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(Icons.view_in_ar_rounded, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    _l10n.text('cards.title'),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _l10n.text(
                      'cards.count',
                      arguments: <String, Object?>{
                        'count': _projections.length,
                      },
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed:
                        _busy || _projections.isEmpty ? null : _openCards,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(_l10n.text('cards.open')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppGlassCard(
            glowColor: Theme.of(context).colorScheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Icon(Icons.bolt_rounded, size: 48),
                const SizedBox(height: 10),
                AppDirectionalText(
                  'مركز المراجعة SRS',
                  languageCode: 'ar',
                  style: AppTypography.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AppDirectionalText(
                  'بطاقات SRS المستحقة من الفهرس المحلي الموثّق، '
                  'مع إحصاءات الجلسة والنطق المحلي والشرح عند الطلب.',
                  languageCode: 'ar',
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const Key('v11-open-quick-review'),
                  onPressed: _busy ? null : _openQuickReview,
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: AppDirectionalText(
                    'افتح مركز المراجعة',
                    languageCode: 'ar',
                    style: AppTypography.label,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  String _taskTitle(CurriculumTask task) {
    final locale = _l10n.snapshot.userLocale.languageCode;
    return locale == 'ar' ? task.titleAr : task.titleDe;
  }

  String _lifeTitle(LifeCurriculumLink link) {
    final locale = _l10n.snapshot.userLocale.languageCode;
    return locale == 'ar' ? link.titleAr : link.titleDe;
  }

  String _titleForIndex(int index) => switch (index) {
        1 => _l10n.text('nav.curriculum'),
        2 => _l10n.text('nav.life'),
        3 => _l10n.text('nav.cards'),
        _ => _l10n.text('app.title'),
      };
}

final class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(detail),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
