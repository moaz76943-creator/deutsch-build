import 'package:flutter/material.dart';

import '../../design_system/app_glass_card.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.2,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    super.key,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      blur: blur,
      opacity: opacity,
      borderRadius: borderRadius,
      padding: padding,
      child: child,
    );
  }
}
