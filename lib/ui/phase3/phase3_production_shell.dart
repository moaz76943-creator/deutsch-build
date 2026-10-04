import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/content_contract.dart';
import '../../core/curriculum/canonical_curriculum_50.dart';
import '../../core/curriculum/curriculum_models.dart';
import '../../core/curriculum/learning_path_engine.dart';
import '../../features/phase3_integration/life_curriculum_catalog.dart';
import '../../features/phase3_integration/production_agent_runtime.dart';
import 'life_task_route_registry.dart';
import 'phase3_flashcards.dart';

final class Phase3ProductionShell extends StatefulWidget {
  const Phase3ProductionShell({
    required this.corpus,
    this.routeRegistry,
    this.deckId = 'main-vocabulary',
    super.key,
  });

  final List<LearningContent> corpus;
  final LifeTaskRouteRegistry? routeRegistry;
  final String deckId;

  @override
  State<Phase3ProductionShell> createState() =>
      _Phase3ProductionShellState();
}

final class _Phase3ProductionShellState extends State<Phase3ProductionShell> {
  late final LifeTaskRouteRegistry _routes;
  late final LifeCurriculumCatalog _catalog;
  late final LearningPathEngine _curriculum;
  late final List<VocabularyFlashcardProjection> _projections;
  late final Phase3AgentRuntime _runtime;

  Phase3DesignProfile? _design;
  int _index = 0;
  bool _busy = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _routes = widget.routeRegistry ?? LifeTaskRouteRegistry();
    _catalog = _routes.catalog;
    _curriculum = LearningPathEngine(CanonicalCurriculum50.tasks);
    _projections = VocabularyProjectionFactory.fromContentList(widget.corpus);
    _runtime = Phase3AgentRuntime.start(
      catalog: _catalog,
      decks: VocabularyProjectionDeckRegistry(
        <String, List<VocabularyFlashcardProjection>>{
          widget.deckId: _projections,
        },
      ),
    );
    unawaited(_loadDesign());
  }

  @override
  void dispose() {
    unawaited(_runtime.close());
    super.dispose();
  }

  Future<void> _loadDesign() async {
    try {
      final design = await _runtime.requestDesign();
      if (!mounted) return;
      setState(() => _design = design);
    } on Object catch (error) {
      _setError('تعذر تحميل إعدادات وكيل التصميم: $error');
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
      _setError('تعذر فتح المهمة: $error');
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
      if (!mounted) return;
      if (ready.cardCount != _projections.length) {
        throw StateError('Card deck count mismatch.');
      }
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => Phase3FlashcardDeckPage(
            title: 'بطاقات المفردات ثلاثية الأبعاد',
            projections: _projections,
          ),
        ),
      );
    } on Object catch (error) {
      _setError('تعذر فتح البطاقات: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() => _lastError = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final direction =
        _design?.direction == 'ltr' ? TextDirection.ltr : TextDirection.rtl;
    final tabs = <Widget>[
      _overviewTab(context),
      _curriculumTab(context),
      _lifeTab(context),
      _cardsTab(context),
    ];

    return Directionality(
      textDirection: direction,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleForIndex(_index)),
          actions: <Widget>[
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
        bottomNavigationBar: _design == null ||
                _design!.navigation == 'bottom'
            ? NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (value) =>
                    setState(() => _index = value),
                destinations: const <NavigationDestination>[
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'الرئيسية',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.route_outlined),
                    selectedIcon: Icon(Icons.route_rounded),
                    label: 'المسار',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.apps_outlined),
                    selectedIcon: Icon(Icons.apps_rounded),
                    label: 'الحياة',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.view_in_ar_outlined),
                    selectedIcon: Icon(Icons.view_in_ar_rounded),
                    label: 'البطاقات',
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _overviewTab(BuildContext context) {
    final design = _design;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _StatusCard(
          icon: Icons.architecture_outlined,
          title: 'الربط الإنتاجي',
          value: design == null ? 'جارٍ التهيئة' : 'نشط',
          detail: design == null
              ? 'يتم طلب إعدادات الواجهة عبر Design Agent.'
              : 'Navigation: ${design.navigation} • Cards: ${design.flashcardMode} • ${design.direction.toUpperCase()}',
        ),
        const SizedBox(height: 12),
        _StatusCard(
          icon: Icons.checklist_rounded,
          title: 'مهام الحياة',
          value: '${_catalog.links.length}/50',
          detail:
              'كل مهمة مرتبطة بمهمة Curriculum ومسجلة في Route Registry.',
        ),
        const SizedBox(height: 12),
        _StatusCard(
          icon: Icons.menu_book_outlined,
          title: 'مسار التعلم',
          value: '${_curriculum.tasks.length} مهمة',
          detail:
              'المسار الأساسي مستخدم مباشرة من CanonicalCurriculum50.',
        ),
        const SizedBox(height: 12),
        _StatusCard(
          icon: Icons.view_in_ar_rounded,
          title: '3D Flashcards',
          value: '${_projections.length} بطاقة',
          detail:
              'LearningContent → VocabularyFlashcardProjection → Flashcard3DData.',
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

  Widget _curriculumTab(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: _curriculum.tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = _curriculum.tasks[index];
          final linked = _catalog.links
              .where((link) => link.curriculumTaskId == task.id)
              .toList(growable: false);

          return Card(
            child: ExpansionTile(
              leading: CircleAvatar(child: Text('${task.order}')),
              title: Text(task.titleAr),
              subtitle: Text(
                '${task.titleDe} • ${task.stage.code}',
                textDirection: TextDirection.ltr,
              ),
              childrenPadding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 14),
              children: <Widget>[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    linked.isEmpty
                        ? 'لا توجد مهمة حياة مباشرة لهذا الدرس.'
                        : 'مهام الحياة المرتبطة: ${linked.length}',
                  ),
                ),
                if (linked.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final link in linked)
                        ActionChip(
                          label: Text(link.titleAr),
                          onPressed: _busy
                              ? null
                              : () => _openLifeTask(link),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      );

  Widget _lifeTab(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: _catalog.links.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final link = _catalog.links[index];
          final task = _curriculum.taskById(link.curriculumTaskId);
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${link.ordinal}')),
              title: Text(link.titleAr),
              subtitle: Text(
                '${link.titleDe}\nمرتبط بالدرس ${task.order}: ${task.titleAr}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
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
                    'بطاقات المفردات ثلاثية الأبعاد',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تحتوي المجموعة الحالية على ${_projections.length} بطاقة مولدة من محتوى التطبيق الفعلي.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed:
                        _busy || _projections.isEmpty ? null : _openCards,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('فتح مجموعة 3D'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  String _titleForIndex(int index) => switch (index) {
        1 => 'مسار التعلم',
        2 => 'مهام الحياة 50/50',
        3 => 'البطاقات ثلاثية الأبعاد',
        _ => 'Deutsch بالعربي',
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
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
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
