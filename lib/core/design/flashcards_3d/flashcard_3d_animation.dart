import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'flashcard_3d_models.dart';

final class Flashcard3DAnimationMath {
  const Flashcard3DAnimationMath({
    this.perspective = .0012,
    this.maxDragTiltRadians = .08,
  })  : assert(perspective > 0),
        assert(maxDragTiltRadians >= 0);

  final double perspective;
  final double maxDragTiltRadians;

  double _unit(double value) => value.clamp(0.0, 1.0).toDouble();

  double rotationFor(double progress) => _unit(progress) * math.pi;

  double dragTiltFor(double dragFraction) =>
      dragFraction.clamp(-1.0, 1.0).toDouble() * maxDragTiltRadians;

  Flashcard3DFace visibleFaceFor(double progress) =>
      _unit(progress) <= .5 ? Flashcard3DFace.front : Flashcard3DFace.back;

  Matrix4 matrixFor(
    double progress, {
    double dragFraction = 0,
  }) {
    return Matrix4.identity()
      ..setEntry(3, 2, perspective)
      ..rotateY(rotationFor(progress))
      ..rotateZ(dragTiltFor(dragFraction));
  }
}

final class Flashcard3DRenderer extends StatefulWidget {
  const Flashcard3DRenderer({
    required this.front,
    required this.back,
    required this.isFlipped,
    this.dragFraction = 0,
    this.duration = const Duration(milliseconds: 320),
    this.curve = Curves.easeInOutCubic,
    this.animationMath = const Flashcard3DAnimationMath(),
    super.key,
  });

  final Widget front;
  final Widget back;
  final bool isFlipped;
  final double dragFraction;
  final Duration duration;
  final Curve curve;
  final Flashcard3DAnimationMath animationMath;

  @override
  State<Flashcard3DRenderer> createState() => _Flashcard3DRendererState();
}

final class _Flashcard3DRendererState extends State<Flashcard3DRenderer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.isFlipped ? 1 : 0,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(covariant Flashcard3DRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.isFlipped != widget.isFlipped) {
      _controller.animateTo(
        widget.isFlipped ? 1 : 0,
        duration: widget.duration,
        curve: widget.curve,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final face = widget.animationMath.visibleFaceFor(progress);
        final visibleChild = face == Flashcard3DFace.front
            ? widget.front
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: widget.back,
              );

        return Transform(
          alignment: Alignment.center,
          transform: widget.animationMath.matrixFor(
            progress,
            dragFraction: widget.dragFraction,
          ),
          child: visibleChild,
        );
      },
    );
  }
}
