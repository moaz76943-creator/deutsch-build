import 'package:flutter/material.dart';

class SafeErrorBoundary extends StatelessWidget {
  final Widget child;
  const SafeErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, size: 48, color: Colors.blueAccent),
                const SizedBox(height: 8),
                const Text(
                  'حدث خطأ غير متوقع في هذا الجزء',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('العودة للواجهة السابقة'),
                ),
              ],
            ),
          ),
        ),
      );
    };
    return child;
  }
}
