import 'package:flutter/material.dart';

class ResilientTextContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResilientTextContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: child,
    );
  }
}
