import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/content_contract.dart';
import '../../../services/preferences_service.dart';
import '../../../services/repository.dart';
import '../../session/universal_session_orchestrator.dart';
import '../application/local_learning_recovery_controller.dart';
import '../application/local_learning_recovery_session_coordinator.dart';
import '../data/local_learning_recovery_state_store.dart';
import '../domain/local_learning_recovery_resume.dart';
import 'local_learning_recovery_host.dart';
import 'widgets/smart_orb.dart';

/// Production orchestration surface for Local Learning Recovery.
///
/// It owns only ephemeral UI/session state plus a bounded resume cursor.
/// Canonical learning progress and SRS writes stay in LearnerRepository through
/// UniversalSessionOrchestrator.
class LocalLearningRecoveryRuntimeHost extends StatefulWidget {
  const LocalLearningRecoveryRuntimeHost({
    super.key,
    required this.repository,
    required this.preferences,
    required this.corpus,
    required this.child,
  });

  final LearnerRepository repository;
  final PreferencesService preferences;
  final List<LearningContent> corpus;
  final Widget child;

  @override
  State<LocalLearningRecoveryRuntimeHost> createState() =>
      _LocalLearningRecoveryRuntimeHostState();
}

class _LocalLearningRecoveryRuntimeHostState
    extends State<LocalLearningRecoveryRuntimeHost>
    with WidgetsBindingObserver {
  late final UniversalSessionOrchestrator _sessionOrchestrator;
  late final LocalLearningRecoveryController _controller;
  late final LocalLearningRecoverySessionCoordinator _coordinator;

  bool _evaluating = false;
  bool _promptOpen = false;
  bool _sessionOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final contentById = <String, LearningContent>{
      for (final item in widget.corpus)
        if (item.id.trim().isNotEmpty) item.id: item,
    };
    _sessionOrchestrator =
        UniversalSessionOrchestrator(repository: widget.repository);
    _controller = LocalLearningRecoveryController(
      repository: widget.repository,
      sessionOrchestrator: _sessionOrchestrator,
      contentLookup: (conceptId) => contentById[conceptId],
    );
    _coordinator = LocalLearningRecoverySessionCoordinator(
      controller: _controller,
      stateStore:
          PreferencesLocalLearningRecoveryStateStore(widget.preferences),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_evaluateReturn());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_evaluateReturn());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _sessionOrchestrator.dispose();
    super.dispose();
  }

  Future<void> _evaluateReturn() async {
    if (!mounted || _evaluating || _promptOpen || _sessionOpen) return;
    _evaluating = true;
    try {
      final plan = await _controller.refreshOnReturn();
      _controller.dismiss();
      if (!mounted || plan == null) return;

      final session = await _coordinator.prepare(plan);
      if (!mounted || session == null) return;

      _promptOpen = true;
      await _coordinator.markPrompted(session);
      if (!mounted) return;
      final start = await showModalBottomSheet<bool>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (sheetContext) => Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: LocalLearningRecoveryPrompt(
            plan: session.plan,
            title: session.resumed
                ? 'نكمل جلسة الاسترجاع؟'
                : 'جلسة استرجاع قصيرة؟',
            message:
                'لديك ${session.plan.items.length} مراجعات محلية، '
                'حوالي ${session.plan.estimatedMinutes} دقائق. '
                'يمكنك التوقف والمتابعة لاحقًا بلا أي عقوبة.',
            actionLabel: session.resumed ? 'متابعة' : 'ابدأ',
            dismissLabel: 'لاحقًا',
            orbSemanticsLabel: 'توجيه جلسة الاسترجاع',
            onStart: () => Navigator.of(sheetContext).pop(true),
            onDismiss: () => Navigator.of(sheetContext).pop(false),
          ),
        ),
      );
      _promptOpen = false;
      if (!mounted || start != true) return;

      await _coordinator.begin(session);
      if (!mounted) return;
      _sessionOpen = true;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => LocalLearningRecoverySessionScreen(
            session: session,
            coordinator: _coordinator,
          ),
        ),
      );
      _sessionOpen = false;
    } on Object {
      _promptOpen = false;
      _sessionOpen = false;
      // Recovery is optional: fail closed without blocking the main learning UI.
    } finally {
      _evaluating = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class LocalLearningRecoverySessionScreen extends StatefulWidget {
  const LocalLearningRecoverySessionScreen({
    super.key,
    required this.session,
    required this.coordinator,
  });

  final LocalLearningRecoverySession session;
  final LocalLearningRecoverySessionCoordinator coordinator;

  @override
  State<LocalLearningRecoverySessionScreen> createState() =>
      _LocalLearningRecoverySessionScreenState();
}

class _LocalLearningRecoverySessionScreenState
    extends State<LocalLearningRecoverySessionScreen> {
  int _index = 0;
  int _correct = 0;
  bool _revealed = false;
  bool _busy = false;
  bool _completed = false;
  DateTime _startedAt = DateTime.now();
  SmartOrbFeedback _feedback = SmartOrbFeedback.neutral;

  void _reveal() {
    if (_revealed || _busy || _completed) return;
    setState(() {
      _revealed = true;
      _feedback = SmartOrbFeedback.guidance;
    });
  }

  Future<void> _grade(bool correct) async {
    if (_busy || _completed) return;
    final elapsed = DateTime.now().difference(_startedAt);
    setState(() => _busy = true);

    try {
      await widget.coordinator.record(
        session: widget.session,
        itemIndex: _index,
        correct: correct,
        elapsed: elapsed,
      );
      if (!mounted) return;

      final last = _index + 1 >= widget.session.plan.items.length;
      setState(() {
        _busy = false;
        if (correct) _correct += 1;
        _feedback =
            correct ? SmartOrbFeedback.success : SmartOrbFeedback.incorrect;
        if (last) {
          _completed = true;
        } else {
          _index += 1;
          _revealed = false;
          _startedAt = DateTime.now();
        }
      });
    } on Object {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر حفظ المراجعة محليًا. بقيت البطاقة في مكانها.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return _LocalLearningRecoveryCompletion(
        reviewed: widget.session.plan.items.length,
        correct: _correct,
      );
    }

    final item = widget.session.plan.items[_index].item;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.resumed ? 'متابعة الاسترجاع' : 'الاسترجاع'),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Center(
                child: SmartOrb(
                  size: 92,
                  semanticsLabel: 'تغذية راجعة للاسترجاع',
                  state: SmartOrbDomainState(feedback: _feedback),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'بطاقة ${_index + 1} من ${widget.session.plan.items.length}',
                style: theme.textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_index + 1) / widget.session.plan.items.length,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 20),
              Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _revealed ? null : _reveal,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: <Widget>[
                        Text(
                          item.sourceText,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (!_revealed)
                          const Text(
                            'استدعِ المعنى أولًا، ثم اضغط لإظهار الإجابة.',
                            textAlign: TextAlign.center,
                          )
                        else ...<Widget>[
                          Text(
                            item.translationText,
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          if (item.exampleText.trim().isNotEmpty) ...<Widget>[
                            const Divider(height: 28),
                            Text(
                              item.exampleText,
                              textAlign: TextAlign.center,
                            ),
                            if (item.exampleTranslationText.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  item.exampleTranslationText,
                                  style: theme.textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (_revealed)
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : () => _grade(false),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('احتاج مراجعة'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _busy ? null : () => _grade(true),
                        icon: _busy
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: const Text('تذكرت'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              Text(
                'الخروج لا يسبب عقوبة. المتبقي محفوظ محليًا للاستئناف.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalLearningRecoveryCompletion extends StatelessWidget {
  const _LocalLearningRecoveryCompletion({
    required this.reviewed,
    required this.correct,
  });

  final int reviewed;
  final int correct;

  @override
  Widget build(BuildContext context) {
    final accuracy = reviewed == 0 ? 0 : ((correct / reviewed) * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('الاسترجاع')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SmartOrb(
                  size: 112,
                  semanticsLabel: 'اكتملت جلسة الاسترجاع',
                  state: SmartOrbDomainState(
                    feedback: SmartOrbFeedback.success,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'اكتملت المراجعة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'راجعت $reviewed عناصر · استدعاء صحيح $accuracy٪',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'هذا يكفي الآن. سيحدد SRS المحلي موعدك التالي، '
                  'ولا توجد سلسلة أو عقوبة على التوقف.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.done_rounded),
                  label: const Text('إنهاء'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
