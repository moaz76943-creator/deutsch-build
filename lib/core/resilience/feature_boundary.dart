import 'package:flutter/material.dart';

import '../concurrency/cancellation_token.dart';
import 'recovery_outcome.dart';
import 'resilient_feature_executor.dart';

abstract class FeatureBoundaryHandle {
  void reportError(Object error, [StackTrace? stackTrace]);
}

class FeatureBoundary extends StatefulWidget {
  const FeatureBoundary({
    super.key,
    required this.featureName,
    required this.child,
    this.fallbackBuilder,
    this.onInitialize,
    this.initializationDependency,
    this.onCriticalFailure,
    this.initializationTimeout = ResilientFeatureExecutor.defaultAttemptTimeout,
    this.maxInitializationAttempts = ResilientFeatureExecutor.defaultMaxAttempts,
  });

  final String featureName;
  final Widget child;
  final Widget Function(BuildContext context, Object error)? fallbackBuilder;
  final Future<void> Function()? onInitialize;
  final Object? initializationDependency;
  final void Function(Object error)? onCriticalFailure;
  final Duration initializationTimeout;
  final int maxInitializationAttempts;

  static FeatureBoundaryHandle? of(BuildContext context) =>
      context.findAncestorStateOfType<_FeatureBoundaryState>();

  @override
  State<FeatureBoundary> createState() => _FeatureBoundaryState();
}

class _FeatureBoundaryState extends State<FeatureBoundary>
    implements FeatureBoundaryHandle {
  final ResilientFeatureExecutor _executor = ResilientFeatureExecutor();
  CancellationToken? _activeToken;
  Object? _caughtError;
  bool _initializing = false;

  @override
  void initState() {
    super.initState();
    _beginInitialization();
  }

  @override
  void didUpdateWidget(covariant FeatureBoundary previous) {
    super.didUpdateWidget(previous);
    if (previous.initializationDependency !=
        widget.initializationDependency) {
      _beginInitialization();
    }
  }

  void _beginInitialization() {
    _activeToken?.cancel();
    _executor.resetSession();
    final initialize = widget.onInitialize;
    _caughtError = null;
    if (initialize == null) {
      _initializing = false;
      return;
    }
    _initializing = true;
    final token = CancellationToken();
    _activeToken = token;
    _runInitialization(token, initialize);
  }

  Future<void> _runInitialization(
      CancellationToken token, Future<void> Function() initialize) async {
    RecoveryOutcome<void> outcome;
    try {
      outcome = await _executor.execute<void>(
        task: initialize,
        cancellationToken: token,
        maxAttempts: widget.maxInitializationAttempts,
        attemptTimeout: widget.initializationTimeout,
      );
    } catch (error, stackTrace) {
      outcome = RecoveryOutcome<void>.failed(error, stackTrace);
    }
    if (!mounted || !identical(_activeToken, token) ||
        token.isCancelled || outcome.isStale || outcome.isCancelled) return;
    if (outcome.isFailed &&
        outcome.error != null &&
        FailureCategorization.isCritical(outcome.error!)) {
      widget.onCriticalFailure?.call(outcome.error!);
    }
    setState(() {
      _initializing = false;
      _caughtError = outcome.isFailed ? outcome.error : null;
    });
  }

  @override
  void reportError(Object error, [StackTrace? stackTrace]) {
    if (FailureCategorization.isCritical(error)) {
      if (stackTrace != null) Error.throwWithStackTrace(error, stackTrace);
      throw error;
    }
    if (mounted) setState(() => _caughtError = error);
  }

  @override
  void dispose() {
    _activeToken?.cancel();
    _executor.resetSession();
    super.dispose();
  }

  Widget _fallback(Object? error) =>
      widget.fallbackBuilder?.call(context, error ?? StateError('Unavailable')) ??
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('تعذر تشغيل ${widget.featureName}'),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_initializing && _caughtError == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text('جاري تحديث ${widget.featureName} تلقائياً...'),
          ],
        ),
      );
    }
    if (_caughtError != null) return _fallback(_caughtError);
    return widget.child;
  }
}
