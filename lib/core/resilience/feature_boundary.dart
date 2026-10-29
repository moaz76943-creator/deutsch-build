import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/resilience/failure_reasons.dart';
import 'package:deutsch_bilarabi/core/resilience/recovery_outcome.dart';

class FeatureBoundary extends StatefulWidget {
  final String featureName;
  final Widget child;
  final Widget Function(BuildContext context, Object error)? fallbackBuilder;
  final Widget Function(BuildContext context, Object error, VoidCallback? onRetry)? fallbackBuilderWithRetry;
  final Future<void> Function()? onInit;
  final int maxRetries;
  final String? sessionKey;

  const FeatureBoundary({
    super.key,
    required this.featureName,
    required this.child,
    this.fallbackBuilder,
    this.fallbackBuilderWithRetry,
    this.onInit,
    this.maxRetries = 3,
    this.sessionKey,
  });

  @override
  State<FeatureBoundary> createState() => _FeatureBoundaryState();
}

class _FeatureBoundaryState extends State<FeatureBoundary> {
  Object? _caughtError;
  int _retryCount = 0;
  int _operationEpoch = 0;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    if (widget.onInit != null) {
      _runInit();
    }
  }

  @override
  void didUpdateWidget(FeatureBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 36, color: Colors.blueGrey.shade400),
            const SizedBox(height: 12),
            Text(
              'حدث خطأ في $featureName',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey.shade700,
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
    }

    return widget.child;
  }
}
