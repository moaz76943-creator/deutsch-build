import 'package:flutter/material.dart';

class AppGradients {
  // تدرج سينمائي عميق متوافق تماماً مع شاشات OLED السوداء لتوفير الطاقة وإبراز الزجاج
  static const LinearGradient darkScaffold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000), // أسود مطلق لشاشات OLED
      Color(0xFF090D16), // أزرق ليلي عميق وهادئ
      Color(0xFF0F172A),
    ],
  );

  static const LinearGradient glassCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x15FFFFFF), // شفافية ناعمة جداً
      Color(0x05FFFFFF),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
