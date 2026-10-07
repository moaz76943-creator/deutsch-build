// App Design System - Post-V1 Expansion (Refactored for Modern Flutter)
import 'package:flutter/material.dart';

class AppDesignSystem {
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  static Color applyAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }
}
