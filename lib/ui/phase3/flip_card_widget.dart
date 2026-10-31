import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FlipCardFace { front, back }

enum FlipCardSwipeDirection { left, right, up, down }

typedef FlipCardFaceChanged = void Function(FlipCardFace face);
typedef FlipCardSwipeChanged = void Function(FlipCardSwipeDirection direction);

final class FlipCardWidget extends StatefulWidget {
  const FlipCardWidget({
    required this.front,
    required this.back,
    required this.semanticLabel,
    this.duration = const Duration(milliseconds: 320),
    this.perspective = 0.0012,
    this.onFaceChanged,
    this.onSwipe,
    this.initiallyFlipped = false,
    super.key,
  });

  final Widget front;
  final Widget back;
  final String semanticLabel;
  final Duration duration;
  final double perspective;
  final FlipCardFaceChanged? onFaceChanged;
  final FlipCardSwipeChanged? onSwipe;
  final bool initiallyFlipped;

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

final class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ValueNotifier<Offset> _dragOffset = ValueNotifier<Offset>(Offset.zero);

  bool get _isBack => _controller.value >= 0.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.initiallyFlipped ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant FlipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.initiallyFlipped != widget.initiallyFlipped) {
      _animateTo(widget.initiallyFlipped);
    }
  }

  @override
  void dispose() {
    _dragOffset.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final toBack = !_isBack;
    await HapticFeedback.selectionClick();
    await _animateTo(toBack);
  }

  Future<void> _animateTo(bool back) async {
    if (!mounted) return;
    await _controller.animateTo(
      back ? 1 : 0,
      duration: widget.duration,
      curve: Curves.easeInOutCubic,
    );
    if (!mounted) return;
    widget.onFaceChanged?.call(
      back ? FlipCardFace.back : FlipCardFace.front,
    );
  }

  void _onPanStart(DragStartDetails details) {
    _dragOffset.value = Offset.zero;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _dragOffset.value += details.delta;
  }

  void _onPanCancel() {
    _dragOffset.value = Offset.zero;
  }

  void _onPanEnd(DragEndDetails details) {
    final offset = _dragOffset.value;
    _dragOffset.value = Offset.zero;

    final velocity = details.velocity.pixelsPerSecond;
    final horizontal = offset.dx.abs() >= offset.dy.abs();
    const displacementThreshold = 42.0;
    const velocityThreshold = 420.0;

    FlipCardSwipeDirection? direction;
    if (horizontal &&
        (offset.dx.abs() >= displacementThreshold ||
            velocity.dx.abs() >= velocityThreshold)) {
      direction = (offset.dx + velocity.dx * 0.04) >= 0
          ? FlipCardSwipeDirection.right
          : FlipCardSwipeDirection.left;
    } else if (!horizontal &&
        (offset.dy.abs() >= displacementThreshold ||
            velocity.dy.abs() >= velocityThreshold)) {
      direction = (offset.dy + velocity.dy * 0.04) >= 0
          ? FlipCardSwipeDirection.down
          : FlipCardSwipeDirection.up;
    }

    if (direction == null) return;
    HapticFeedback.lightImpact();
    widget.onSwipe?.call(direction);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      hint: 'Tap to flip. Swipe to record a learning action.',
      child: GestureDetector(
        key: const ValueKey<String>('phase10-flip-card'),
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanCancel: _onPanCancel,
        onPanEnd: _onPanEnd,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[
              _controller,
              _dragOffset,
            ]),
            builder: (context, child) {
              final progress = _controller.value;
              final rotation = progress * math.pi;
              final drag = _dragOffset.value;
              final dragRotation =
                  (drag.dx / 900).clamp(-0.08, 0.08).toDouble();
              final visibleBack = progress > 0.5;

              final matrix = Matrix4.identity()
                ..setEntry(3, 2, widget.perspective)
                ..rotateY(rotation + dragRotation);

              final face = visibleBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: widget.back,
                    )
                  : widget.front;

              return Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: face,
              );
            },
          ),
        ),
      ),
    );
  }
}
