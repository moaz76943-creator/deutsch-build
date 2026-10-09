import 'package:flutter/material.dart';
export 'app_typography.dart';
export '../core/app_haptics.dart';

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
  static const LinearGradient heroSunset = LinearGradient(
    colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
  );
}

class AppBaseGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const AppBaseGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? Colors.white.withOpacity(0.08) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: child,
      ),
    );
  }
}
