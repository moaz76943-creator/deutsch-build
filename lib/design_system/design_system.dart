import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppGradients {
  static const LinearGradient darkScaffold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000), // أسود مطلق لشاشات OLED
      Color(0xFF03050C),
      Color(0xFF0F172A),
    ],
  );

  // طبقات العمق المزمن للزجاج الرقمي (Chronomorphic Ambient Depth)
  static LinearGradient chronomorphicGlassCard(int continuousFocusMinutes) {
    if (continuousFocusMinutes > 20) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x2A10B981), // تدرج أخضر مهدئ وعميق عند استمرار التأمل الطويل
          Color(0x0A065F46),
          Color(0x02FFFFFF),
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x22FFFFFF),
        Color(0x08FFFFFF),
        Color(0x02FFFFFF),
      ],
    );
  }
}

class AppBaseGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final int focusMinutes;

  const AppBaseGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.focusMinutes = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.chronomorphicGlassCard(focusMinutes),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
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
