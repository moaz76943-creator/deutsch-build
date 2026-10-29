import 'package:flutter/material.dart';
import '../concurrency/cancellation_token.dart';
import 'recovery_outcome.dart';
import 'resilient_feature_executor.dart';

class FeatureBoundary extends StatefulWidget {
  final String featureName;
  final Widget child;
  final Widget Function(BuildContext, Object)? fallbackBuilder;
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

  static void report(BuildContext context, Object error) {
    context.findAncestorStateOfType<_FeatureBoundaryState>()?._report(error);
  }

  @override
  State<FeatureBoundary> createState() => _FeatureBoundaryState();
}

class _FeatureBoundaryState extends State<FeatureBoundary> {
  final ResilientFeatureExecutor _executor = ResilientFeatureExecutor();
  CancellationToken? _token;
  Object? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.onInitialize != null) _initialize();
  }

  @override
  void didUpdateWidget(covariant FeatureBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Callback closures may be recreated during ordinary parent rebuilds.
    // Reinitialize only when a feature is enabled/disabled or its explicit
    // dependency identity changes; otherwise retries could form a loop.
    final enabledChanged = (widget.onInitialize == null) !=
        (oldWidget.onInitialize == null);
    final dependencyChanged = widget.initializationDependency != null &&
        widget.initializationDependency != oldWidget.initializationDependency;
    if (enabledChanged || dependencyChanged) {
      _token?.cancel();
      _executor.resetSession();
      if (widget.onInitialize != null) {
        _initialize();
      } else {
        setState(() {
          _loading = false;
          _error = null;
        });
      }
    }
  }

  void _report(Object error) {
    if (FailureCategorization.isCritical(error)) throw error;
    if (mounted) setState(() => _error = error);
  }

  Future<void> _initialize() async {
    final task = widget.onInitialize;
    if (task == null) return;
    _token?.cancel();
    final token = CancellationToken();
    _token = token;
    if (mounted) setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final outcome = await _executor.execute<void>(
        task: task, cancellationToken: token,
      );
      if (!mounted || !identical(_token, token)) return;
      setState(() {
        _loading = false;
        if (outcome.isFailed) _error = outcome.error;
      });
    } catch (error, stack) {
      if (!mounted || !identical(_token, token)) return;
      if (FailureCategorization.isCritical(error)) {
        // Surface integrity failures to the framework's error channel.
        // Optional-feature fallback must not silently classify them as safe.
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'runtime feature boundary',
          context: ErrorDescription('critical initialization failure'),
        ));
      }
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  @override
  void dispose() {
    _token?.cancel();
    _executor.resetSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return widget.fallbackBuilder?.call(context, _error!) ??
          Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('تعذر تشغيل ${widget.featureName}'),
          ));
    }
    return widget.child;
  }
}
