/// سياسة تكيفية لتأثيرات Glassmorphism لحماية معدل 60/120 FPS
class VisualEffectsPolicy {
  final bool enableHeavyBlur;
  final double maxBlurSigma;
  final bool enableLiveGlow;

  const VisualEffectsPolicy({
    this.enableHeavyBlur = true,
    this.maxBlurSigma = 16.0,
    this.enableLiveGlow = true,
  });

  /// إعدادات خفيفة ومحسنة للأجهزة الاقتصادية
  factory VisualEffectsPolicy.powerSaver() {
    return const VisualEffectsPolicy(
      enableHeavyBlur: false,
      maxBlurSigma: 4.0,
      enableLiveGlow: false,
    );
  }

  /// إعدادات كاملة للأداء العالي
  factory VisualEffectsPolicy.highPerformance() {
    return const VisualEffectsPolicy(
      enableHeavyBlur: true,
      maxBlurSigma: 20.0,
      enableLiveGlow: true,
    );
  }
}
