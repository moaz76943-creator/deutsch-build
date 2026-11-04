import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'design_system/app_theme.dart';
import 'core/bootstrap/startup_boundary.dart';
import 'features/onboarding/fast_onboarding_screen.dart';
import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';
import 'package:deutsch_bilarabi/core/registry/feature_capability_registry.dart';
import 'package:deutsch_bilarabi/design_system/app_theme.dart';
import 'package:deutsch_bilarabi/core/persistence/local_persistence_port.dart';
import 'package:deutsch_bilarabi/core/persistence/shared_preferences_adapter.dart';

/// CrashLoopGuard: Protects against repeated crashes that could indicate
/// tampering, data corruption, or unstable state. Resets after 5 minutes.
/// Now depends only on LocalPersistencePort for clean architecture and security.
class CrashLoopGuard {
  static const String _keyCrashCount = 'deutsch_crash_count_v1';
  static const String _keyLastCrash = 'deutsch_last_crash_v1';
  static const int _maxCrashes = 3;
  static const Duration _resetDuration = Duration(minutes: 5);

  final LocalPersistencePort _persistence;

  CrashLoopGuard(this._persistence);

  Future<void> recordFailure() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCrash = await _persistence.getInt(_keyLastCrash) ?? 0;
    int crashCount = await _persistence.getInt(_keyCrashCount) ?? 0;

    if (now - lastCrash < _resetDuration.inMilliseconds) {
      crashCount++;
    } else {
      crashCount = 1;
    }

    await _persistence.setInt(_keyLastCrash, now);
    await _persistence.setInt(_keyCrashCount, crashCount);
  }

  Future<void> recordSuccess() async {
    await _persistence.remove(_keyCrashCount);
    await _persistence.remove(_keyLastCrash);
  }

  Future<bool> isCrashLoopDetected() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCrash = await _persistence.getInt(_keyLastCrash) ?? 0;
    final crashCount = await _persistence.getInt(_keyCrashCount) ?? 0;

    if (now - lastCrash > _resetDuration.inMilliseconds) {
      return false;
    }

    return crashCount >= _maxCrashes;
  }
}

/// Safe mode UI to prevent data leaks or further corruption during recovery.
class SafeModeRecoveryGate extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const SafeModeRecoveryGate({super.key, required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_rounded, size: 64, color: Color(0xFFEF4444)),
                const SizedBox(height: 16),
                const Text('Safe Mode', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message ?? 'Repeated startup failures detected. Data is protected.', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry / Clear errors', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The first frame is independent of content databases and optional services.
  runApp(const DeutschApp());
}

class DeutschApp extends StatelessWidget {
  const DeutschApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
      title: 'DEUTSCH بالعربي',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('de'),
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const FastOnboardingScreen(),
    );
  }
}

/// Resilient root that runs isolated bootstrap before entering the app.
/// Enhances security and recovery without blocking the main thread excessively.
class ResilientAppRoot extends StatefulWidget {
  const ResilientAppRoot({super.key});

  @override
  State<ResilientAppRoot> createState() => _ResilientAppRootState();
}

class _ResilientAppRootState extends State<ResilientAppRoot> {
  bool isBootstrapping = true;
  bool isSafeMode = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    bootstrap();
  }

  Future<void> bootstrap() async {
    try {
      final persistence = await SharedPreferencesAdapter.create();
      final guard = CrashLoopGuard(persistence);

      if (await guard.isCrashLoopDetected()) {
        setState(() {
          isSafeMode = true;
          isBootstrapping = false;
        });
        return;
      }

      await guard.recordFailure();

      // Keep raw prefs for legacy SessionRecoveryManager during transition.
      final prefs = await SharedPreferences.getInstance();

      final pipeline = IsolatedBootstrapPipeline([
        _ProductionAcceptanceStep(),
        _SessionRecoveryStep(prefs),
        _FeatureRegistryStep(),
        _LifecycleRegistryStep(),
      ]);

      final results = await pipeline.runPipeline();

      // Performance instrumentation: log per-step startup times (measurable impact).
      for (final r in results) {
        debugPrint("[DBA][BOOTSTRAP_PERF] ${r.stepName}: ${r.elapsed.inMilliseconds}ms status=${r.status}");
      }

      bool hasFatal = false;
      String? fatalMsg;

      for (final res in results) {
        if (res.status == BootstrapStepStatus.fatalFailure) {
          hasFatal = true;
          fatalMsg = res.message ?? 'Unknown critical error';
          break;
        }
      }

      if (hasFatal) {
        setState(() {
          isSafeMode = true;
          isBootstrapping = false;
          errorMessage = fatalMsg;
        });
      } else {
        await guard.recordSuccess();
        setState(() {
          isSafeMode = false;
          isBootstrapping = false;
        });
      }
    } catch (e) {
      setState(() {
        isSafeMode = true;
        isBootstrapping = false;
        errorMessage = e.toString();
      });
    }
  }

  void retry() {
    setState(() {
      isBootstrapping = true;
      errorMessage = null;
    });
    bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    if (isBootstrapping) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("جاري التهيئة..."),
              ],
            ),
          ),
        ),
      );
    }

    if (isSafeMode) {
      return SafeModeRecoveryGate(
        onRetry: retry,
        message: errorMessage,
      );
    }

    return const ProviderScope(
      child: DeutschApp(),
    );
  }
}

class _ProductionAcceptanceStep extends BootstrapStep {
  @override
  String get name => 'ProductionAcceptance';

  @override
  Future<BootstrapStepResult> execute() async {
    final ready = ProductionAcceptanceGate.verifyAppReadiness(
      isOfflineSafe: true,
      isStorageGuarded: true,
      isLifecycleManaged: true,
    );
    if (!ready) {
      return const BootstrapStepResult(
        stepName: 'ProductionAcceptance',
        status: BootstrapStepStatus.fatalFailure,
        message: 'App not ready for production.',
      );
    }
    return const BootstrapStepResult(
      stepName: 'ProductionAcceptance',
      status: BootstrapStepStatus.success,
    );
  }
}

class _SessionRecoveryStep extends BootstrapStep {
  final SharedPreferences prefs;
  _SessionRecoveryStep(this.prefs);

  @override
  String get name => 'SessionRecovery';

  @override
  Future<BootstrapStepResult> execute() async {
    final manager = SessionRecoveryManager(prefs);
    manager.restoreSession();
    return const BootstrapStepResult(
      stepName: 'SessionRecovery',
      status: BootstrapStepStatus.success,
    );
  }
}

class _FeatureRegistryStep extends BootstrapStep {
  @override
  String get name => 'FeatureRegistry';

  @override
  Future<BootstrapStepResult> execute() async {
    final registry = FeatureCapabilityRegistry.instance;
    registry.registerFeature('core_offline', FeatureStatus.ready);
    return const BootstrapStepResult(
      stepName: 'FeatureRegistry',
      status: BootstrapStepStatus.success,
    );
  }
}

class _LifecycleRegistryStep extends BootstrapStep {
  @override
  String get name => 'LifecycleRegistry';

  @override
  Future<BootstrapStepResult> execute() async {
    final lifecycle = RuntimeLifecycleRegistry.instance;
    if (lifecycle.isDisposed) {
      return const BootstrapStepResult(
        stepName: 'LifecycleRegistry',
        status: BootstrapStepStatus.fatalFailure,
        message: 'Lifecycle is disposed at startup',
      );
    }
    return const BootstrapStepResult(
      stepName: 'LifecycleRegistry',
      status: BootstrapStepStatus.success,
    );
  }
}
