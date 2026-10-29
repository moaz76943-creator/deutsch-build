import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';

import 'features/onboarding/fast_onboarding_screen.dart';
import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';
import 'package:deutsch_bilarabi/core/bootstrap/integrity_bootstrap_step.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';
import 'package:deutsch_bilarabi/core/registry/feature_capability_registry.dart';
import 'package:deutsch_bilarabi/design_system/app_theme.dart';
import 'package:deutsch_bilarabi/core/resilience/crash_loop_guard.dart';
import 'package:deutsch_bilarabi/core/resilience/safe_mode_recovery_gate.dart';

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
=======

import 'bootstrap/production_bootstrap.dart';
import 'design_system/app_theme.dart';
import 'features/onboarding/fast_onboarding_screen.dart';

/// One entry point. Crash-loop accounting, pack admission, and session
/// recovery live in the production shell's startup boundary. This file does
/// not open learner storage.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await bootstrapDeutschApp(const DeutschApp());
>>>>>>> origin/staging/v2-full-platform
}

class DeutschApp extends StatelessWidget {
  const DeutschApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
      final prefs = await SharedPreferences.getInstance();
      final guard = CrashLoopGuard(prefs);

      if (guard.isCrashLoopDetected()) {
        setState(() {
          isSafeMode = true;
          isBootstrapping = false;
        });
        return;
      }

      await guard.recordFailure();

      final pipeline = IsolatedBootstrapPipeline([
        _ProductionAcceptanceStep(),
        _SessionRecoveryStep(prefs),
        _FeatureRegistryStep(),
        _LifecycleRegistryStep(),
        IntegrityBootstrapStep(), // Play Integrity attestation for anti-modding and feature gating
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
=======
    return ProviderScope(
      child: MaterialApp(
        title: 'Deutsch بالعربي',
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
        home: hostProductionShell(
          child: const FastOnboardingScreen(),
        ),
      ),
>>>>>>> origin/staging/v2-full-platform
    );
  }
}
