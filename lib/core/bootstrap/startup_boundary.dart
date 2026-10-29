import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/crash_loop_guard.dart';
import '../../services/database_service.dart';
import '../lifecycle/runtime_lifecycle_registry.dart';
import '../recovery/session_recovery_manager.dart';
import '../registry/feature_capability_registry.dart';
import 'isolated_bootstrap_pipeline.dart';

enum StartupState {
  INITIALIZING,
  READY,
  DEGRADED,
  SAFE_MODE,
  CRITICAL_ERROR,
}

class StartupOutcome {
  const StartupOutcome(this.state, {this.contentAvailable = false});

  final StartupState state;
  final bool contentAvailable;
}

/// Allows deterministic widget tests without touching learner storage.
abstract class StartupOperations {
  Future<StartupOutcome> start();
  Future<void> markStable();
  Future<void> exitSafeMode();
  Future<StartupOutcome> continueSafeOffline();
}

/// Reuses existing crash-loop, database and session contracts. No pack
/// downloader, TTS, network request or bulk 100-language loading occurs here.
class DeviceStartupOperations implements StartupOperations {
  DeviceStartupOperations({CrashLoopGuard? guard, this.extraSteps})
      : _guard = guard ?? CrashLoopGuard.instance;

  final CrashLoopGuard _guard;
  final List<BootstrapStep>? extraSteps;
  Future<bool>? _bootFuture;

  @override
  Future<StartupOutcome> start() async {
    try {
      // A UI retry is not a new Android process launch. Count the launch
      // exactly once or a manual retry would falsely trigger crash-loop mode.
      final bootFuture = _bootFuture ??=
          _guard.beginBoot().timeout(const Duration(seconds: 3));
      if (await bootFuture) {
        return const StartupOutcome(StartupState.SAFE_MODE);
      }
    } catch (_) {
      return const StartupOutcome(StartupState.CRITICAL_ERROR);
    }

    // Preference access is a critical local-storage dependency. Never erase
    // user settings or progress in an effort to recover from a failed open.
    late final SharedPreferences preferences;
    try {
      preferences = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      return const StartupOutcome(StartupState.CRITICAL_ERROR);
    }

    late final List<BootstrapStepResult> results;
    try {
      final steps = <BootstrapStep>[
        _LocalSessionStep(preferences),
        _ActiveContentStep(),
        _LifecycleStep(),
        if (extraSteps != null) ...extraSteps!,
      ];
      results = await IsolatedBootstrapPipeline(steps)
          .runPipeline()
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      return const StartupOutcome(StartupState.CRITICAL_ERROR);
    }

    if (results.any((r) => r.status == BootstrapStepStatus.fatalFailure)) {
      return const StartupOutcome(StartupState.CRITICAL_ERROR);
    }

    final contentAvailable = results.any(
      (r) =>
          r.stepName == 'active_content' &&
          r.status == BootstrapStepStatus.success,
    );
    FeatureCapabilityRegistry.instance.registerFeature(
      'core_offline',
      contentAvailable ? FeatureStatus.ready : FeatureStatus.available,
    );

    final hasOptionalFailure = results.any(
      (r) => r.status == BootstrapStepStatus.recoverableFailure,
    );
    if (hasOptionalFailure || !contentAvailable) {
      // Keep the last-known-good marker; never replace it with a failed boot.
      return StartupOutcome(
        StartupState.DEGRADED,
        contentAvailable: contentAvailable,
      );
    }

    try {
      // Startup-only marker, kept separate from all existing learner settings.
      final saved = await preferences
          .setBool('bootstrap.last_ready.v1', true)
          .timeout(const Duration(seconds: 2));
      if (!saved) {
        return const StartupOutcome(
          StartupState.DEGRADED,
          contentAvailable: true,
        );
      }
    } catch (_) {
      return const StartupOutcome(
        StartupState.DEGRADED,
        contentAvailable: true,
      );
    }
    return const StartupOutcome(
      StartupState.READY,
      contentAvailable: true,
    );
  }

  @override
  Future<void> markStable() => _guard.markStable();

  @override
  Future<void> exitSafeMode() async {
    await _guard.exitAfterRecovery();
    _bootFuture = Future<bool>.value(false);
  }

  @override
  Future<StartupOutcome> continueSafeOffline() async {
    // Keep the crash ledger in safe mode; only bundled German is eligible.
    try {
      await DatabaseService.instance
          .getContentDb('de')
          .timeout(const Duration(seconds: 7));
      return const StartupOutcome(
        StartupState.DEGRADED,
        contentAvailable: true,
      );
    } catch (_) {
      return const StartupOutcome(StartupState.DEGRADED);
    }
  }
}

class _LocalSessionStep extends BootstrapStep {
  _LocalSessionStep(this.preferences);
  final SharedPreferences preferences;

  @override
  String get name => 'local_session';

  @override
  bool get isCritical => false;

  @override
  Future<BootstrapStepResult> execute() async {
    // Malformed session metadata returns null without modifying persisted data.
    SessionRecoveryManager(preferences).restoreSession();
    return const BootstrapStepResult(
      stepName: 'local_session',
      status: BootstrapStepStatus.success,
    );
  }
}

class _ActiveContentStep extends BootstrapStep {
  @override
  String get name => 'active_content';

  @override
  bool get isCritical => false;

  @override
  Duration get timeout => const Duration(seconds: 7);

  @override
  Future<BootstrapStepResult> execute() async {
    // One active-language pack only; no download and no progress DB migration.
    // Errors (including missing/malformed packs) become a visible fallback.
    await DatabaseService.instance.getContentDb('de');
    return const BootstrapStepResult(
      stepName: 'active_content',
      status: BootstrapStepStatus.success,
    );
  }
}

class _LifecycleStep extends BootstrapStep {
  @override
  String get name => 'lifecycle';

  @override
  Future<BootstrapStepResult> execute() async {
    if (RuntimeLifecycleRegistry.instance.isDisposed) {
      return const BootstrapStepResult(
        stepName: 'lifecycle',
        status: BootstrapStepStatus.fatalFailure,
      );
    }
    return const BootstrapStepResult(
      stepName: 'lifecycle',
      status: BootstrapStepStatus.success,
    );
  }
}

/// A visible first frame is mounted before any boot I/O. Only user actions
/// invoke retries; late completions cannot mutate a disposed/restarted UI.
class StartupBoundary extends StatefulWidget {
  const StartupBoundary({
    super.key,
    required this.child,
    this.operations,
    this.startupTimeout = const Duration(seconds: 19),
    this.stabilityWindow = const Duration(seconds: 6),
  });

  final Widget child;
  final StartupOperations? operations;
  final Duration startupTimeout;
  final Duration stabilityWindow;

  @override
  State<StartupBoundary> createState() => _StartupBoundaryState();
}

class _StartupBoundaryState extends State<StartupBoundary> {
  late final StartupOperations _operations;
  StartupState _state = StartupState.INITIALIZING;
  bool _contentAvailable = false;
  int _generation = 0;
  int _manualRetries = 0;
  bool _safeSession = false;
  Timer? _stableTimer;

  @override
  void initState() {
    super.initState();
    _operations = widget.operations ?? DeviceStartupOperations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start();
    });
  }

  Future<void> _start() async {
    final generation = ++_generation;
    StartupOutcome outcome;
    try {
      outcome = await _operations.start().timeout(widget.startupTimeout);
    } catch (_) {
      outcome = const StartupOutcome(StartupState.CRITICAL_ERROR);
    }
    if (!mounted || generation != _generation) return;
    setState(() {
      _state = outcome.state;
      _contentAvailable = outcome.contentAvailable;
      _safeSession = outcome.state == StartupState.SAFE_MODE;
    });
    if (_state == StartupState.READY || _state == StartupState.DEGRADED) {
      _stableTimer?.cancel();
      _stableTimer = Timer(widget.stabilityWindow, () {
        if (!mounted || generation != _generation) return;
        // Ledger failure must not throw into Flutter's scheduler.
        _operations.markStable().catchError((Object _) {});
      });
    }
  }

  void _retry() {
    if (_manualRetries >= 1) return;
    _manualRetries++;
    _stableTimer?.cancel();
    setState(() {
      _state = StartupState.INITIALIZING;
      _contentAvailable = false;
    });
    _start();
  }

  Future<void> _continueSafeOffline() async {
    final generation = ++_generation;
    setState(() => _state = StartupState.INITIALIZING);
    StartupOutcome outcome;
    try {
      outcome = await _operations
          .continueSafeOffline()
          .timeout(const Duration(seconds: 9));
    } catch (_) {
      outcome = const StartupOutcome(StartupState.DEGRADED);
    }
    if (!mounted || generation != _generation) return;
    setState(() {
      _state = StartupState.DEGRADED;
      _contentAvailable = outcome.contentAvailable;
      _safeSession = true;
    });
  }

  Future<void> _exitAndRetry() async {
    if (_manualRetries >= 1) return;
    _manualRetries++;
    final generation = ++_generation;
    setState(() => _state = StartupState.INITIALIZING);
    try {
      await _operations.exitSafeMode().timeout(const Duration(seconds: 4));
    } catch (_) {
      // Remain in safe mode. Never clear learner data or bypass recovery.
      if (mounted && generation == _generation) {
        setState(() => _state = StartupState.SAFE_MODE);
      }
      return;
    }
    if (!mounted || generation != _generation) return;
    _start();
  }

  @override
  void dispose() {
    ++_generation;
    _stableTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case StartupState.INITIALIZING:
        return const Scaffold(
          body: Center(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تهيئة التطبيق دون اتصال...'),
                ],
              ),
            ),
          ),
        );
      case StartupState.READY:
        return widget.child;
      case StartupState.DEGRADED:
        if (_contentAvailable) {
          return Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                      'بعض الميزات الاختيارية غير متاحة. يمكنك المتابعة دون اتصال.'),
                ),
              ),
              Expanded(child: widget.child),
            ],
          );
        }
        return _recoveryScreen(
          icon: Icons.menu_book_outlined,
          title: 'المحتوى غير متاح حاليًا',
          description:
              'تعذر التحقق من حزمة اللغة المحلية. بيانات التعلّم محفوظة. '
              'يمكنك المحاولة مجددًا بعد التأكد من تثبيت الحزمة.',
          retry: _manualRetries < 1 && !_safeSession ? _retry : null,
        );
      case StartupState.SAFE_MODE:
        return _recoveryScreen(
          icon: Icons.health_and_safety_outlined,
          title: 'الوضع الآمن',
          description: 'تم اكتشاف تشغيل سابق غير مكتمل. لن تُحذف بيانات '
              'التعلّم أو تُعاد تهيئة الحزم تلقائيًا.',
          retry: _manualRetries < 1 ? _exitAndRetry : null,
          secondaryAction: _continueSafeOffline,
          secondaryLabel: 'متابعة آمنة بالمحتوى المحلي',
        );
      case StartupState.CRITICAL_ERROR:
        return _recoveryScreen(
          icon: Icons.error_outline,
          title: 'تعذر بدء الخدمات الأساسية',
          description:
              'قد تكون وحدة التخزين المحلية أو خدمات الإقلاع غير متاحة. '
              'لم تُحذف سجلاتك. أغلق التطبيق وتحقق من مساحة التخزين إذا استمرت المشكلة.',
          retry: _manualRetries < 1 ? _retry : null,
        );
    }
  }

  Widget _recoveryScreen({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback? retry,
    VoidCallback? secondaryAction,
    String? secondaryLabel,
  }) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 52),
                    const SizedBox(height: 20),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text(description, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    if (retry != null)
                      FilledButton(
                        onPressed: retry,
                        child: const Text('إعادة المحاولة مرة واحدة'),
                      ),
                    if (secondaryAction != null) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: secondaryAction,
                        child: Text(secondaryLabel ?? 'متابعة دون اتصال'),
                      ),
                    ],
                    if (retry == null && secondaryAction == null)
                      const Text('لا توجد محاولات استعادة إضافية لهذه الجلسة.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
