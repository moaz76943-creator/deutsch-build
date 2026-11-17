/// Modern Material Design 3 motion tokens for smooth, accessible animations.
/// Respects system reduced-motion preferences when used with MediaQuery.
class AppMotion {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration cardFlip = Duration(milliseconds: 300);
  static const Duration pageTransition = Duration(milliseconds: 300);

  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve standard = Curves.easeInOut;
  static const Curve decelerate = Curves.decelerate;

  static const double elevationIdle = 1.0;
  static const double elevationHovered = 3.0;
  static const double elevationPressed = 0.0;
  static const double card3dPerspective = 0.0012;
}
