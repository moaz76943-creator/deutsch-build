import 'package:flutter/material.dart';

/// رموز موحدة لظلال وتوهج النمط الزجاجي لحماية أداء GPU
class ElevationTokens {
  ElevationTokens._();

  static const List<BoxShadow> low = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> glowAccent = [
    BoxShadow(
      color: Color(0x4D6366F1),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
