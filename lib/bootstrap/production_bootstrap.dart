import 'dart:async';

import 'package:flutter/foundation.dart'
    show FlutterError, FlutterErrorDetails, kReleaseMode;
import 'package:flutter/widgets.dart';

import '../core/bootstrap/startup_boundary.dart';
import 'production_runtime.dart';

final ProductionRuntimeCoordinator productionRuntimeCoordinator =
    ProductionRuntimeCoordinator();

/// Release builds keep the crash details off the console. Debug and profile
/// builds still use Flutter's presenter. This type has no print path.
final class NoopRuntimeFailureReporter {
  const NoopRuntimeFailureReporter();

  void recordFlutterError(FlutterErrorDetails details) {
    if (!kReleaseMode) {
      FlutterError.presentError(details);
    }
  }
}

/// Current production home. The deleted phase-3 screen module is not restored;
/// the shell hosts whatever widget the app passes in.
class Phase3ProductionShell extends StatelessWidget {
  const Phase3ProductionShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Recovery host for the current app. Startup accounting, safe mode, and the
/// "learner data is kept" path live in [StartupBoundary].
class LocalLearningRecoveryRuntimeHost extends StatelessWidget {
  const LocalLearningRecoveryRuntimeHost({
    super.key,
    required this.child,
    this.operations,
    this.stabilityWindow = const Duration(seconds: 6),
  });

  final Widget child;
  final StartupOperations? operations;
  final Duration stabilityWindow;

  @override
  Widget build(BuildContext context) {
    return StartupBoundary(
      operations: operations,
      stabilityWindow: stabilityWindow,
      child: child,
    );
  }
}

/// Composes the production shell around [child]. The app widget itself is
/// built by the caller so this file does not construct it.
Widget hostProductionShell({
  required Widget child,
  StartupOperations? operations,
  Duration stabilityWindow = const Duration(seconds: 6),
}) {
  return LocalLearningRecoveryRuntimeHost(
    operations: operations,
    stabilityWindow: stabilityWindow,
    child: Phase3ProductionShell(
      child: child,
    ),
  );
}

/// Installs the release error boundary, schedules a non-destructive first-frame
/// hook, then mounts [app]. Does not open the progress database.
Future<void> bootstrapDeutschApp(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();

  const runtimeFailureReporter = NoopRuntimeFailureReporter();
  FlutterError.onError = runtimeFailureReporter.recordFlutterError;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(productionRuntimeCoordinator.noteFirstFrame());
  });

  runApp(app);
}
