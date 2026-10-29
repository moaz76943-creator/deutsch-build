import 'package:flutter/material.dart';
import '../concurrency/cancellation_token.dart';
import 'recovery_outcome.dart';
import 'resilient_feature_executor.dart';

class FeatureBoundary extends StatefulWidget {
  final String featureName;
  final Widget child;
  final Widget Function(BuildContext context, Object error)? fallbackBuilder;
  final Future<void> Function()? onInitialize;
  final Object? initializationDependency;

  const FeatureBoundary({
    super.key,
    required this.featureName,
    required this.child,
    this.fallbackBuilder,
    this.onInitialize,
    this.initializationDependency,
  });

  static _FeatureBoundaryState? of(BuildContext context) {
    return context.findAncestorStateOfType<_FeatureBoundaryState>();
  }

  @override
  State<FeatureBoundary> createState() => _FeatureBoundaryState();
}

class _FeatureBoundaryState extends State<FeatureBoundary> {
  Object? _caughtError;
  bool _isInitializing = false;
  late ResilientFeatureExecutor _executor;
  CancellationToken? _cancellationToken;

  @override
  void initState() {
    super.initState();
    _executor = ResilientFeatureExecutor();
    if (widget.onInitialize != null) {
      _executeInitialization();
    }
  }

  @override
  void didUpdateWidget(FeatureBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onInitialize != null &&
        widget.initializationDependency != null &&
        oldWidget.initializationDependency != widget.initializationDependency) {
      _executor.resetSession();
      _executeInitialization();
    }
  }

  @override
  void dispose() {
    _cancellationToken?.cancel();
    super.dispose();
  }

  Future<void> _executeInitialization() async {
    _cancellationToken?.cancel();
    final currentToken = CancellationToken();
    _cancellationToken = currentToken;

    if (mounted) {
      setState(() {
        _isInitializing = true;
        _caughtError = null;
      });
    }

    final outcome = await _executor.execute(
      task: widget.onInitialize!,
      cancellationToken: currentToken,
    );

    if (!mounted) return;

    // Ignore updates if this task was cancelled by a newer one
    if (_cancellationToken != currentToken) return;

    setState(() {
      _isInitializing = false;
      if (outcome.isFailed) {
        _caughtError = outcome.error;
      }
    });
  }

  void reportError(Object error, [StackTrace? stackTrace]) {
    if (FailureCategorization.isCritical(error)) {
      if (stackTrace != null) {
        Error.throwWithStackTrace(error, stackTrace);
      } else {
        throw error;
      }
    }

    if (mounted) {
      setState(() {
        _caughtError = error;
      });
    }
  }

  static Widget _defaultFallback(BuildContext context, String featureName, Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 36, color: Colors.blueGrey.shade400),
            const SizedBox(height: 12),
            Text(
              'تعذر تشغيل $featureName',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing && _caughtError == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'جاري تحديث ${widget.featureName} تلقائياً...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    if (_caughtError != null) {
      return widget.fallbackBuilder?.call(context, _caughtError!) ??
          _defaultFallback(context, widget.featureName, _caughtError);
    }

    return widget.child;
  }
}
