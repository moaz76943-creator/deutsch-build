import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class AppGlassCard extends StatefulWidget {
  const AppGlassCard({
    required this.child,
    this.onTap,
    this.blur = 18,
    this.opacity = .12,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.glowColor,
    this.backgroundColor = Colors.white,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;
  final Color backgroundColor;

  @override
  State<AppGlassCard> createState() => _AppGlassCardState();
}

class _AppGlassCardState extends State<AppGlassCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _scale;

  AnimationController get _controller => _scale ??= AnimationController.unbounded(
        vsync: this,
        value: 1,
      );

  void _springTo(double target) {
    _controller.animateWith(
      SpringSimulation(
        const SpringDescription(
          mass: .8,
          stiffness: 520,
          damping: 32,
        ),
        _controller.value,
        target,
        0,
      ),
    );
  }

  @override
  void dispose() {
    _scale?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius.clamp(20.0, 28.0).toDouble();
    final alpha = (widget.opacity.clamp(0.0, 1.0) * 255).round();
    final border = widget.borderColor ?? Colors.white.withAlpha(72);
    final glow = widget.glowColor;

    final surface = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blur,
          sigmaY: widget.blur,
        ),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor.withAlpha(alpha),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border, width: 1.2),
            boxShadow: glow == null
                ? const <BoxShadow>[]
                : <BoxShadow>[
                    BoxShadow(
                      color: glow.withAlpha(34),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap == null) return surface;

    final controller = _controller;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _springTo(.975),
        onTapCancel: () => _springTo(1),
        onTapUp: (_) => _springTo(1),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: controller,
          child: surface,
          builder: (context, child) {
            final value = controller.value.clamp(.94, 1.02).toDouble();
            return Transform.scale(scale: value, child: child);
          },
        ),
      ),
    );
  }
}
