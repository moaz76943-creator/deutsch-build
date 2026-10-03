import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'app_glass_card.dart';
import 'app_typography.dart';

class AppAudioButton extends StatelessWidget {
  const AppAudioButton({
    required this.onPressed,
    required this.semanticLabel,
    this.isActive = false,
    this.isBusy = false,
    this.icon = FontAwesomeIcons.volumeHigh,
    this.activeColor = const Color(0xFF38BDF8),
    super.key,
  });

  final VoidCallback? onPressed;
  final String semanticLabel;
  final bool isActive;
  final bool isBusy;
  final FaIconData icon;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isBusy;
    final color = enabled ? activeColor : Colors.white38;

    Widget button = Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: AppGlassCard(
        onTap: enabled ? onPressed : null,
        borderRadius: 22,
        blur: 16,
        opacity: .10,
        glowColor: isActive ? activeColor : null,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: isBusy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: activeColor,
                    ),
                  )
                : FaIcon(icon, size: 18, color: color),
          ),
        ),
      ),
    );

    if (isActive) {
      button = button
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(.98, .98),
            end: const Offset(1.035, 1.035),
            duration: 700.ms,
          )
          .fade(
            begin: .88,
            end: 1,
            duration: 700.ms,
          );
    }

    return Tooltip(
      message: semanticLabel,
      textStyle: AppTypography.label.copyWith(color: Colors.white),
      child: button,
    );
  }
}
