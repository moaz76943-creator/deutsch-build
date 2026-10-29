import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'dart:async';
import 'bounded_retry_policy.dart';
import 'feature_recovery_outcome.dart';
=======
import 'package:deutsch_bilarabi/core/resilience/failure_reasons.dart';
import 'package:deutsch_bilarabi/core/resilience/recovery_outcome.dart';
>>>>>>> origin/main

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
  final Widget Function(BuildContext context, Object error, VoidCallback? onRetry)? fallbackBuilderWithRetry;
  final Future<void> Function()? onInit;
  final int maxRetries;
  final String? sessionKey;
>>>>>>> origin/main

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
    this.fallbackBuilderWithRetry,
    this.onInit,
    this.maxRetries = 3,
    this.sessionKey,
>>>>>>> origin/main
  });

  @override
  State<FeatureBoundary> createState() => _FeatureBoundaryState();
}

class _FeatureBoundaryState extends State<FeatureBoundary> {
  Object? _caughtError;
<<<<<<< HEAD
  FeatureRecoveryOutcome? _outcome;
  bool _isInitializing = false;
  String? _activeSessionId;
  bool _isDisposed = false;
=======
  int _retryCount = 0;
  int _operationEpoch = 0;
  bool _isInitializing = false;
>>>>>>> origin/main

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _activeSessionId = widget.sessionId;
    if (widget.initializationAction != null) {
      _runInitialization();
=======
    if (widget.onInit != null) {
      _runInit();
>>>>>>> origin/main
    }
  }

  @override
  void didUpdateWidget(FeatureBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
<<<<<<< HEAD
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
    if (widget.sessionKey != oldWidget.sessionKey) {
      _operationEpoch++; // Cancel ongoing operations
      _retryCount = 0;
      _caughtError = null;
      if (widget.onInit != null) {
        _runInit();
      }
    }
  }

  Future<RecoveryOutcome> _runInit() async {
    if (widget.onInit == null) return const RecoverySuccess();

    setState(() {
      _isInitializing = true;
      _caughtError = null;
    });

    final currentEpoch = _operationEpoch;

    try {
      await widget.onInit!();

      if (!mounted || currentEpoch != _operationEpoch) {
        return const RecoveryCancelled();
      }

      setState(() {
        _isInitializing = false;
      });
      return const RecoverySuccess();
    } catch (e) {
      if (!mounted || currentEpoch != _operationEpoch) {
        return const RecoveryCancelled();
      }

      if (e is CriticalIntegrityFailure) {
        // Fail-closed for critical errors
        rethrow;
      }

      setState(() {
        _isInitializing = false;
        _caughtError = e;
      });
      return RecoveryFailed(e);
    }
  }

  void retry() {
    if (_isInitializing || _retryCount >= widget.maxRetries) return;

    setState(() {
      _retryCount++;
    });
    _runInit();
  }

  static Widget _defaultFallback(
    BuildContext context,
    String featureName,
    Object? error,
    VoidCallback? onRetry,
  ) {
>>>>>>> origin/main
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 36, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
<<<<<<< HEAD
              'تعذر تشغيل $featureName',
=======
              'حدث خطأ في $featureName',
>>>>>>> origin/main
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
<<<<<<< HEAD
      return const Center(child: CircularProgressIndicator());
    }

    if (_caughtError != null || _outcome is RecoveryBlocked) {
      return widget.fallbackBuilder?.call(
              context, _caughtError ?? (_outcome as RecoveryBlocked).message) ??
          _defaultFallback(context, widget.featureName, _caughtError);
=======
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text('جاري تحديث ${widget.featureName} تلقائياً...'),
          ],
        ),
      );
    }

    if (_caughtError != null) {
      final canRetry = _retryCount < widget.maxRetries && widget.onInit != null;

      if (widget.fallbackBuilderWithRetry != null) {
        return widget.fallbackBuilderWithRetry!(context, _caughtError!, canRetry ? retry : null);
      }
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(context, _caughtError!);
      }

      return _defaultFallback(context, widget.featureName, _caughtError, canRetry ? retry : null);
>>>>>>> origin/main
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

    return widget.child;
  }
}
