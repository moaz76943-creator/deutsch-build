import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bootstrap/production_bootstrap.dart';
import 'design_system/app_theme.dart';
import 'features/onboarding/fast_onboarding_screen.dart';

import 'core/bootstrap/isolated_bootstrap_pipeline.dart';
import 'core/recovery/session_recovery_manager.dart';
import 'core/registry/feature_capability_registry.dart';
import 'core/resilience/crash_loop_guard.dart';
import 'core/resilience/safe_mode_recovery_gate.dart';
import 'core/quality/production_acceptance_gate.dart';
import 'core/lifecycle/runtime_lifecycle_registry.dart';

/// One entry point. Crash-loop accounting, pack admission, and session
/// recovery live in the production shell's startup boundary. This file does
/// not open learner storage.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await bootstrapDeutschApp(const ResilientAppRoot());
}

class ResilientAppRoot extends StatefulWidget {
  const ResilientAppRoot({super.key});

  @override
  State<ResilientAppRoot> createState() => _ResilientAppRootState();
}

class _ResilientAppRootState extends State<ResilientAppRoot> {
  bool _isInitializing = true;
  bool _isSafeMode = false;
  String? _errorMessage;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guard = CrashLoopGuard(prefs);

      if (guard.isCrashLoopDetected()) {
        if (mounted && !_isDisposed) {
          setState(() {
            _isInitializing = false;
            _isSafeMode = true;
            _errorMessage = 'وضعية الاسترداد الآمن (Safe Mode)';
          });
        }
        return;
      }

      await guard.recordFailure();

      final pipeline = IsolatedBootstrapPipeline([
        _LifecycleStep(),
        _SessionRecoveryStep(prefs),
        _FeatureCapabilityStep(),
      ]);

      final results = await pipeline.runPipeline();

      bool hasFatal = results.any((r) => r.status == BootstrapStepStatus.fatalFailure);
      if (hasFatal) {
        if (mounted && !_isDisposed) {
          setState(() {
            _isInitializing = false;
            _isSafeMode = true;
            _errorMessage = 'فشل التهيئة الأساسية';
          });
        }
        return;
      }

      final contract = J025StartupContract(
         isOfflineSafe: true,
         isStorageGuarded: true,
         isLifecycleManaged: true,
         hasOptionalAudio: FeatureCapabilityRegistry.instance.getStatus('audio_pack_de') == FeatureStatus.available || FeatureCapabilityRegistry.instance.getStatus('audio_pack_de') == FeatureStatus.ready,
      );

      final readiness = ProductionAcceptanceGate.evaluateReadiness(contract);
      if (readiness.eligibility == PromotionEligibility.blocked) {
          if (mounted && !_isDisposed) {
            setState(() {
              _isInitializing = false;
              _isSafeMode = true;
              _errorMessage = 'Critical DB Integrity Error';
            });
          }
          return;
      }

      await guard.recordSuccess();

      if (mounted && !_isDisposed) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitializing = false;
          _isSafeMode = true;
          _errorMessage = 'Critical DB Integrity Error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("جاري التهيئة..."),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isSafeMode) {
      return SafeModeRecoveryGate(
        message: _errorMessage,
        onRetry: () async {
          final prefs = await SharedPreferences.getInstance();
          await CrashLoopGuard(prefs).recordSuccess();
          if (mounted && !_isDisposed) {
            setState(() {
              _isInitializing = true;
              _isSafeMode = false;
              _errorMessage = null;
            });
            _initializeApp();
          }
        },
      );
    }

    return const DeutschApp();
  }
}

class _LifecycleStep extends BootstrapStep {
  @override
  String get name => 'lifecycle';

  @override
  bool get isCritical => true;

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

class _SessionRecoveryStep extends BootstrapStep {
  final SharedPreferences prefs;
  _SessionRecoveryStep(this.prefs);

  @override
  String get name => 'session_recovery';

  @override
  bool get isCritical => false;

  @override
  Future<BootstrapStepResult> execute() async {
    final manager = SessionRecoveryManager(prefs);
    manager.restoreSession();
    return const BootstrapStepResult(
      stepName: 'session_recovery',
      status: BootstrapStepStatus.success,
    );
  }
}

class _FeatureCapabilityStep extends BootstrapStep {
  @override
  String get name => 'feature_capability';

  @override
  bool get isCritical => false;

  @override
  Future<BootstrapStepResult> execute() async {
    final status = FeatureCapabilityRegistry.instance.getStatus('audio_pack_de');
    if (status == FeatureStatus.unsupported) {
      return const BootstrapStepResult(
        stepName: 'feature_capability',
        status: BootstrapStepStatus.recoverableFailure,
      );
    }
    return const BootstrapStepResult(
      stepName: 'feature_capability',
      status: BootstrapStepStatus.success,
    );
  }
}

class DeutschApp extends StatelessWidget {
  const DeutschApp({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
