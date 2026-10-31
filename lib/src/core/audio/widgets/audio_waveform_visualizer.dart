import 'package:flutter/material.dart';

/// Lightweight custom painter rendering responsive audio waveform bars.
class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color activeColor;
  final Color inactiveColor;
  final double playbackFraction;

  WaveformPainter({
    required this.amplitudes,
    required this.activeColor,
    required this.inactiveColor,
    required this.playbackFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final barWidth = size.width / (amplitudes.length * 1.5);
    final spacing = barWidth * 0.5;
    final totalBarWidth = barWidth + spacing;

    final paintActive = Paint()..color = activeColor;
    final paintInactive = Paint()..color = inactiveColor;

    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * totalBarWidth;
      final barHeight = size.height * amplitudes[i];
      final y = (size.height - barHeight) / 2;

      final isPast = (i / amplitudes.length) <= playbackFraction;
      final paint = isPast ? paintActive : paintInactive;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.playbackFraction != playbackFraction ||
        oldDelegate.amplitudes != amplitudes;
  }
}

/// Visualizer widget animating waveform during audio playback.
class AudioWaveformVisualizer extends StatelessWidget {
  final List<double> amplitudes;
  final double playbackFraction;
  final double height;
  final double width;
  final Color? activeColor;
  final Color? inactiveColor;

  const AudioWaveformVisualizer({
    super.key,
    required this.amplitudes,
    required this.playbackFraction,
    this.height = 36.0,
    this.width = double.infinity,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: WaveformPainter(
          amplitudes: amplitudes,
          playbackFraction: playbackFraction.clamp(0.0, 1.0),
          activeColor: activeColor ?? theme.colorScheme.primary,
          inactiveColor: inactiveColor ?? theme.colorScheme.surfaceVariant,
        ),
      ),
    );
  }
}
