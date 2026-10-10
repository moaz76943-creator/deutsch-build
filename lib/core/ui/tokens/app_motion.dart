/// ثوابت الحركة التفاعلية لتوفير تجربة بصرية 60fps مستقرة
class AppMotion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration cardFlip = Duration(milliseconds: 320);

  static const double elevationIdle = 1.0;
  static const double elevationHovered = 4.0;
  static const double elevationPressed = 0.5;
  static const double card3dPerspective = 0.0015;
}
