import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppGradients {
  static const LinearGradient darkScaffold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000), // أسود مطلق لشاشات OLED
      Color(0xFF050811),
      Color(0xFF0F172A),
    ],
  );

  // تأثير التشتت تحت السطحي للزجاج الرقمي (Subsurface Scattering)
  static const LinearGradient glassCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x22FFFFFF), // إضاءة علوية ناعمة
      Color(0x08FFFFFF),
      Color(0x02FFFFFF), // تشتت عميق
    ],
  );
}

class AppBaseGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppBaseGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.glassCard,
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
