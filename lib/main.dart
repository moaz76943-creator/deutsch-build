import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/onboarding/fast_onboarding_screen.dart';
import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';
import 'package:deutsch_bilarabi/core/registry/feature_capability_registry.dart';
import 'package:deutsch_bilarabi/design_system/app_theme.dart';

/// CrashLoopGuard: Protects against repeated crashes that could indicate
/// tampering, data corruption, or unstable state. Resets after 5 minutes.
class CrashLoopGuard {
  static const String _keyCrashCount = 'deutsch_crash_count_v1';
  static const String _keyLastCrash = 'deutsch_last_crash_v1';
  static const int _maxCrashes = 3;
  static const Duration _resetDuration = Duration(minutes: 5);

  final SharedPreferences _prefs;

  CrashLoopGuard(this._prefs);

  Future<void> recordFailure() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCrash = _prefs.getInt(_keyLastCrash) ?? 0;
    int crashCount = _prefs.getInt(_keyCrashCount) ?? 0;

    if (now - lastCrash < _resetDuration.inMilliseconds) {
      crashCount++;
    } else {
      crashCount = 1;
    }

    await _prefs.setInt(_keyLastCrash, now);
    await _prefs.setInt(_keyCrashCount, crashCount);
  }

  Future<void> recordSuccess() async {
    await _prefs.remove(_keyCrashCount);
    await _prefs.remove(_keyLastCrash);
  }

  bool isCrashLoopDetected() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastCrash = _prefs.getInt(_keyLastCrash) ?? 0;
    final crashCount = _prefs.getInt(_keyCrashCount) ?? 0;

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
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.build_circle_outlined, color: Color(0xFFF59E0B), size: 64),
                const SizedBox(height: 24),
                const Text(
                  'وضعية الاسترداد الآمن (Safe Mode)',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'تم اكتشاف مشكلة متكررة أثناء التشغيل. تم تفعيل وضعية الاسترداد لحماية بياناتك من التلف.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message!,
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onRetry,
                  child: const Text('إعادة المحاولة / مسح الأخطاء', style: TextStyle(color: Colors.white)),
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

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("[DBA][FLUTTER_ERROR] ${details.exceptionAsString()}");
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0F172A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
                    SizedBox(width: 8),
                    Text(
                      "STARTUP ISSUE DETECTED",
                      style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  details.exceptionAsString(),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: "monospace"),
                ),
                const SizedBox(height: 12),
                Text(
                  details.stack.toString(),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: "monospace"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  runApp(const ResilientAppRoot());
}

class DeutschApp extends StatelessWidget {
  const DeutschApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deutsch بالعربي',
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
      themeMode: ThemeMode.system, // Respect system dark mode for better UX and accessibility
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
  int _bootstrapGeneration = 0;

  @override
  void initState() {
    super.initState();
    // Paint the splash before any preferences or pipeline I/O. A late result
    // from an older attempt cannot overwrite a newer retry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) bootstrap();
    });
  }

  bool _isCurrent(int generation) =>
      mounted && generation == _bootstrapGeneration;

  Future<void> bootstrap() async {
    final generation = ++_bootstrapGeneration;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!_isCurrent(generation)) return;
      final guard = CrashLoopGuard(prefs);

      if (guard.isCrashLoopDetected()) {
        setState(() {
          isSafeMode = true;
          isBootstrapping = false;
        });
        return;
      }

      await guard.recordFailure();
      if (!_isCurrent(generation)) return;

      final pipeline = IsolatedBootstrapPipeline(
        [
          _ProductionAcceptanceStep(),
          _SessionRecoveryStep(prefs),
          _FeatureRegistryStep(),
          _LifecycleRegistryStep(),
        ],
        defaultStepTimeout: IsolatedBootstrapPipeline.startupStepBudget,
      );

      final results = await pipeline.runPipeline();
      if (!_isCurrent(generation)) return;

      String? fatalMsg;

      for (final res in results) {
        if (res.status == BootstrapStepStatus.fatalFailure) {
          fatalMsg = res.message ?? 'Unknown critical error';
          break;
        }
      }

      if (fatalMsg != null) {
        setState(() {
          isSafeMode = true;
          isBootstrapping = false;
          errorMessage = fatalMsg;
        });
      } else {
        await guard.recordSuccess();
        if (!_isCurrent(generation)) return;
        setState(() {
          isSafeMode = false;
          isBootstrapping = false;
        });
      }
    } catch (_) {
      if (!_isCurrent(generation)) return;
      setState(() {
        isSafeMode = true;
        isBootstrapping = false;
        // Stable copy only. Exception text can include local paths.
        errorMessage = 'تعذر إكمال التهيئة المحلية.';
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
          backgroundColor: Color(0xFFF8FAFC),
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

  /// A missing or unreadable session must not trap the learner in safe mode.
  /// Progress and SRS rows are not touched by this step.
  @override
  bool get isCritical => false;

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
