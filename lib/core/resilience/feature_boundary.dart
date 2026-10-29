import 'package:flutter/material.dart';

class FeatureBoundary extends StatefulWidget {
  final String featureName;
  final Widget child;
  final Widget Function(BuildContext context, Object error)? fallbackBuilder;

  const FeatureBoundary({
    super.key,
    required this.featureName,
    required this.child,
    this.fallbackBuilder,
  });

  @override
  State<FeatureBoundary> createState() => _FeatureBoundaryState();
}

class _FeatureBoundaryState extends State<FeatureBoundary> {
  Object? _caughtError;

  @override
  void initState() {
    super.initState();
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
              'جاري تحديث $featureName تلقائياً...',
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
    if (_caughtError != null) {
      return widget.fallbackBuilder?.call(context, _caughtError!) ??
          _defaultFallback(context, widget.featureName, _caughtError);
    }

    return widget.child;
  }
}
