import 'package:flutter/material.dart';
export 'app_typography.dart';

class AppGradients {
  static const LinearGradient purpleCard = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
  );
  static const LinearGradient darkScaffold = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF121212)],
  );
}

class AppBaseGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppBaseGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: child,
      ),
    );
  }
}
