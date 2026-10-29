import 'package:flutter/foundation.dart';

/// Release-safe crash reporting boundary.
///
/// Phase 17 intentionally ships with a no-op implementation. A future
/// first-party/approved reporter can implement this contract without changing
/// global Flutter error handling or exposing exception details to release logs.
abstract interface class RuntimeFailureReporter {
  void recordFlutterError(FlutterErrorDetails details);

  void record(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
    required String context,
  });
}

final class NoopRuntimeFailureReporter implements RuntimeFailureReporter {
  const NoopRuntimeFailureReporter();

  @override
  void recordFlutterError(FlutterErrorDetails details) {}

  @override
  void record(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
    required String context,
  }) {}
}
