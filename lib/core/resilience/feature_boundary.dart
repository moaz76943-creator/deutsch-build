import 'package:flutter/material.dart';
import 'dart:async';
import '../architecture/operation_result.dart';
import 'bounded_retry_policy.dart';
import 'failure_reasons.dart';
import 'feature_recovery_outcome.dart';

class FeatureBoundary extends StatefulWidget {
  final String featureName;
  final Widget child;
  final Widget Function(BuildContext context, Object error)? fallbackBuilder;
  final Widget Function(BuildContext context, FeatureFailureReason reason)?
      degradedBuilder;
  final Future<void> Function()? initializationAction;
  final BoundedRetryPolicy? retryPolicy;
  final String? sessionId;

  const FeatureBoundary({
    super.key,
    required this.featureName,
    required this.child,
    this.fallbackBuilder,
    this.degradedBuilder,
    this.initializationAction,
    this.retryPolicy,
    this.sessionId,
  });

  /// Critical storage and vault failures leave the boundary. Optional
  /// failures stay in the degraded UI and must not be rethrown from here.
  static void report(BuildContext context, Object error) {
    if (context.findAncestorStateOfType<_FeatureBoundaryState>() == null) {
      throw StateError('FeatureBoundary.report requires a FeatureBoundary');
    }
    if (error is StorageFailure || error is CriticalIntegrityFailure) {
      throw error;
    }
  }

  @override
  State<FeatureBoundary> createState() => _FeatureBoundaryState();
}

class _FeatureBoundaryState extends State<FeatureBoundary> {
  Object? _caughtError;
  FeatureRecoveryOutcome? _outcome;
  bool _isInitializing = false;
  String? _activeSessionId;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _activeSessionId = widget.sessionId;
    if (widget.initializationAction != null) {
      _runInitialization();
    }
  }

  @override
  void didUpdateWidget(FeatureBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sessionId != oldWidget.sessionId) {
      _activeSessionId = widget.sessionId;
      // Stale callback protection via new sessionId
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _runInitialization() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    final policy = widget.retryPolicy ?? BoundedRetryPolicy();
    final currentSession = _activeSessionId;

    FeatureRecoveryOutcome outcome;
    Object? criticalError;
    try {
      outcome = await policy.execute<void>(() async {
        await widget.initializationAction!();
      }, sessionId: currentSession, isDisposed: () => _isDisposed);
    } on StorageFailure catch (error) {
      // Keep critical failures blocked and visible instead of leaking an
      // unhandled future and leaving initialization on its spinner.
      criticalError = error;
      outcome = RecoveryOutcomeHelper.classifyFailure(error);
    }

    if (!mounted || _activeSessionId != currentSession) {
      // Reject stale callback if session changed or unmounted
      return;
    }

    setState(() {
      _outcome = outcome;
      _isInitializing = false;
      if (outcome is RecoveryBlocked) {
        _caughtError = criticalError ?? outcome.message;
      }
    });
  }

  static Widget _defaultFallback(
      BuildContext context, String featureName, Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 36, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              'تعذر تشغيل $featureName',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _defaultDegraded(
    BuildContext context,
    String featureName,
    FeatureFailureReason reason, {
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber, size: 36, color: Colors.orange.shade400),
            const SizedBox(height: 12),
            Text(
              'يعمل $featureName بوضع محدود',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.orange.shade700,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_caughtError != null || _outcome is RecoveryBlocked) {
      return widget.fallbackBuilder?.call(
              context, _caughtError ?? (_outcome as RecoveryBlocked).message) ??
          _defaultFallback(context, widget.featureName, _caughtError);
    }

    if (_outcome is RecoveryDegraded) {
      final degradedOutcome = _outcome as RecoveryDegraded;
      return Column(mainAxisSize: MainAxisSize.min, children: [
        widget.degradedBuilder?.call(context, degradedOutcome.reason) ??
            _defaultDegraded(
              context,
              widget.featureName,
              degradedOutcome.reason,
              onRetry: _runInitialization,
            ),
        Flexible(child: widget.child),
      ]);
    }

    return widget.child;
  }
}
