import 'dart:math';
import 'package:flutter/material.dart';

class CardPhysicsHelper {
  static Matrix4 compute3dFlipTransform(double animationValue) {
    final double angle = animationValue * pi;
    return Matrix4.identity()
      ..setEntry(3, 2, 0.001) // عمق الرؤية ثلاثي الأبعاد
      ..rotateY(angle);
  }

  static bool isBackSide(double animationValue) {
    return animationValue >= 0.5;
  }
}
