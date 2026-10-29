import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'dart:async';
import 'bounded_retry_policy.dart';
import 'feature_recovery_outcome.dart';
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

class FeatureBoundary extends StatefulWidget {
  final String featureName;
  final Widget child;
  final Widget Function(BuildContext context, Object error)? fallbackBuilder;
<<<<<<< HEAD
  final Widget Function(BuildContext context, FeatureFailureReason reason)?
      degradedBuilder;
  final Future<void> Function()? initializationAction;
  final BoundedRetryPolicy? retryPolicy;
  final String? sessionId;
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

  const FeatureBoundary({
    super.key,
    required this.featureName,
    required this.child,
    this.fallbackBuilder,
<<<<<<< HEAD
    this.degradedBuilder,
    this.initializationAction,
    this.retryPolicy,
    this.sessionId,
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
  });

  @override
  State<FeatureBoundary> createState() => _FeatureBoundaryState();
}

class _FeatureBoundaryState extends State<FeatureBoundary> {
  Object? _caughtError;
<<<<<<< HEAD
  FeatureRecoveryOutcome? _outcome;
  final bool _isInitializing = false;
  String? _activeSessionId;
  bool _isDisposed = false;
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
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

    final outcome = await policy.execute<void>(() async {
      await widget.initializationAction!();
    }, sessionId: currentSession, isDisposed: () => _isDisposed);

    if (!mounted || _activeSessionId != currentSession) {
      // Reject stale callback if session changed or unmounted
      return;
    }

    setState(() {
      _outcome = outcome;
      _isInitializing = false;
      if (outcome is RecoveryBlocked) {
        _caughtError = outcome.message;
      }
    });
  }

  static Widget _defaultFallback(
      BuildContext context, String featureName, Object? error) {
=======
  }

  static Widget _defaultFallback(BuildContext context, String featureName, Object? error) {
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
<<<<<<< HEAD
            Icon(Icons.error_outline, size: 36, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              'تعذر تشغيل $featureName',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade700,
=======
            Icon(Icons.auto_awesome, size: 36, color: Colors.blueGrey.shade400),
            const SizedBox(height: 12),
            Text(
              'جاري تحديث $featureName تلقائياً...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey.shade700,
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
              ),
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD

  static Widget _defaultDegraded(
      BuildContext context, String featureName, FeatureFailureReason reason) {
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
                context, widget.featureName, degradedOutcome.reason),
        Flexible(child: widget.child),
      ]);
    }

=======

  @override
  Widget build(BuildContext context) {
    if (_caughtError != null) {
      return widget.fallbackBuilder?.call(context, _caughtError!) ??
          _defaultFallback(context, widget.featureName, _caughtError);
    }

>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    return widget.child;
  }
}
