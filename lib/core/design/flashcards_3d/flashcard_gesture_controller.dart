import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'flashcard_3d_models.dart';

final class FlashcardGestureController extends ChangeNotifier {
  FlashcardGestureController({
    this.swipeThresholdFraction = .22,
    this.minimumSwipeDistance = 64,
  })  : assert(swipeThresholdFraction > 0 && swipeThresholdFraction <= 1),
        assert(minimumSwipeDistance > 0);

  final double swipeThresholdFraction;
  final double minimumSwipeDistance;

  Offset _dragOffset = Offset.zero;
  bool _dragging = false;

  Offset get dragOffset => _dragOffset;
  bool get isDragging => _dragging;

  void beginDrag() {
    _dragging = true;
    if (_dragOffset != Offset.zero) {
      _dragOffset = Offset.zero;
    }
    notifyListeners();
  }

  void updateDrag(Offset delta) {
    if (!_dragging) beginDrag();
    _dragOffset += delta;
    notifyListeners();
  }

  void cancelDrag() {
    final changed = _dragging || _dragOffset != Offset.zero;
    _dragging = false;
    _dragOffset = Offset.zero;
    if (changed) notifyListeners();
  }

  FlashcardSwipeDirection? endDrag(Size viewport) {
    final direction = _classify(viewport);
    _dragging = false;
    _dragOffset = Offset.zero;
    notifyListeners();
    return direction;
  }

  double horizontalFraction(Size viewport) {
    final width = math.max(1.0, viewport.width);
    return (_dragOffset.dx / width).clamp(-1.0, 1.0).toDouble();
  }

  double verticalFraction(Size viewport) {
    final height = math.max(1.0, viewport.height);
    return (_dragOffset.dy / height).clamp(-1.0, 1.0).toDouble();
  }

  FlashcardSwipeDirection? _classify(Size viewport) {
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;
    final horizontalThreshold = math.max(
      minimumSwipeDistance,
      viewport.width * swipeThresholdFraction,
    );
    final verticalThreshold = math.max(
      minimumSwipeDistance,
      viewport.height * swipeThresholdFraction,
    );

    if (dx.abs() >= dy.abs() && dx.abs() >= horizontalThreshold) {
      return dx < 0
          ? FlashcardSwipeDirection.left
          : FlashcardSwipeDirection.right;
    }

    if (dy.abs() > dx.abs() && dy.abs() >= verticalThreshold) {
      return dy < 0
          ? FlashcardSwipeDirection.up
          : FlashcardSwipeDirection.down;
    }

    return null;
  }
}
