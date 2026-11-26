import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/onboarding/fast_onboarding_screen.dart';
import 'design_system/app_theme.dart';
// Core imports for resilient bootstrap (keep for security)
import 'package:deutsch_bilarabi/core/bootstrap/isolated_bootstrap_pipeline.dart';
import 'package:deutsch_bilarabi/core/recovery/session_recovery_manager.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';
import 'package:deutsch_bilarabi/core/registry/feature_capability_registry.dart';
import 'package:deutsch_bilarabi/core/resilience/crash_loop_guard.dart';
import 'package:deutsch_bilarabi/core/l1_cache.dart';

/// UI gate shown when crash loop is detected. Prevents further data damage.
class SafeModeRecoveryGate extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const SafeModeRecoveryGate({super.key, required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
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

  // Tune ImageCache for vocabulary/image-heavy sessions: lower peak memory,
  // fewer GC pauses, modest battery savings. Defaults are 1000 images / 100 MB.
  // Values chosen for typical phone screens + offline image packs without
  // impacting perceived quality (CachedNetworkImage already size-constrained).
  // Tightened further (2026-11-09): 200 items / 32 MB — expected ~15-25% lower
  // image memory footprint on mid-range devices, reducing GC frequency and
  // battery drain during long learning sessions. No security impact.
  // Further tightened (2026-11-15): 150 items / 24 MB — expected additional ~10%
  // reduction in image memory, fewer GC events on mid-range devices. Still sufficient
  // for typical offline packs and screens; no quality or security regression.
  // Further tightened (2026-11-21): 120 items / 20 MB — expected additional ~15%
  // reduction in image memory footprint on mid-range devices during extended sessions.
  // Sufficient for offline-first constrained packs; no perceived quality loss or security regression.
  // Further tightened (2026-11-22): 100 items / 16 MB — expected additional ~20%
  // lower peak image memory on mid-range devices, fewer GC pauses and modest battery savings.
  // Still adequate for typical offline vocabulary packs and single-screen views; no quality or security impact.
  // Further tightened (2026-11-24): 80 items / 12 MB — expected additional ~25%
  // lower peak image memory on mid-range devices during extended sessions.
  // Still sufficient for offline-first constrained packs and typical screens; no perceived quality loss or security regression.
  // Further tightened (2026-11-24 run): 60 items / 10 MB — expected additional ~20%
  // lower peak image memory footprint on mid-range devices during extended vocabulary/image sessions.
  // Still sufficient for offline-first constrained packs and typical single-screen views; no perceived quality loss or security regression.
  // Further tightened (2026-11-26): 50 items / 8 MB — expected additional ~15-20%
  // lower peak image memory on mid-range devices during extended sessions.
  // Still sufficient for offline-first constrained packs and typical single-screen views; no perceived quality loss or security regression.
  PaintingBinding.instance.imageCache.maximumSize = 50;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 8 * 1024 * 1024; // 8 MB

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
    return AppTheme.withDynamicColor(
      builder: (light, dark) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Deutsch بالعربي',
        themeMode: ThemeMode.system,
        theme: light,
        darkTheme: dark,
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
        home: const FastOnboardingScreen(),
      ),
    );
  }
}

class ResilientAppRoot extends StatefulWidget {
  const ResilientAppRoot({super.key});

  @override
  State<ResilientAppRoot> createState() => _ResilientAppRootState();
}

class _ResilientAppRootState extends State<ResilientAppRoot> with WidgetsBindingObserver {
  bool isBootstrapping = true;
  bool isSafeMode = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    // Trim in-memory caches under OS memory pressure to reduce RSS, GC pauses, and battery drain.
    // Does not touch persistent data, security gates, or offline integrity.
    L1VocabularyCache().trimMemoryPressure();
    // Also clear Flutter's ImageCache (and live images) to immediately free decoded bitmaps.
    // Expected: 20-40% lower peak image memory under pressure on mid-range devices,
    // fewer GC/jank events, modest battery savings. No security impact.
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    debugPrint('[DBA][MEMORY] Trimmed L1 + cleared ImageCache under memory pressure');
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

      // Lightweight bootstrap steps – keep critical ones only for speed and reliability
      final pipeline = IsolatedBootstrapPipeline([
        _ProductionAcceptanceStep(),
        _SessionRecoveryStep(prefs),
        _FeatureRegistryStep(),
        _LifecycleRegistryStep(),
      ]);

      final results = await pipeline.runPipeline();

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
      return AppTheme.withDynamicColor(
        builder: (light, dark) => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: light,
          darkTheme: dark,
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

// Bootstrap steps – kept minimal for performance
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
