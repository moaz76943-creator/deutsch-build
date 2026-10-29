import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppGradients {
  static const LinearGradient darkScaffold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000), // أسود مطلق لشاشات OLED
      Color(0xFF020408),
      Color(0xFF0F172A),
    ],
  );

  // التدرج الكروماتيكي المتجانس مع الطيف الحيوي وحالة العبء العصبي
  static LinearGradient biophilicSpectrumFlow(bool isOverloaded) {
    if (isOverloaded) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x330284C7), // تدرج أزرق هادئ ومواسي عند رصد العبء العصبي الحاد
          Color(0x110369A1),
          Color(0x02FFFFFF),
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x24FFFFFF),
        Color(0x0AFFFFFF),
        Color(0x02FFFFFF),
      ],
    );
  }
}

class AppBaseGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isOverloaded;

  const AppBaseGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.isOverloaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.biophilicSpectrumFlow(isOverloaded),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOverloaded ? const Color(0xFF38BDF8).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppHaptics {
  static void light() => HapticFeedback.lightImpact();
  static void growthTrigger() => HapticFeedback.mediumImpact();
  static void deepFixation() => HapticFeedback.heavyImpact();
}
