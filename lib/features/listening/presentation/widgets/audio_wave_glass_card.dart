import 'package:flutter/material.dart';

import '../../../../design_system/app_audio_button.dart';
import '../../../../design_system/app_colors.dart';
import '../../../../design_system/app_glass_card.dart';
import '../../../../design_system/app_typography.dart';

class AudioWaveGlassCard extends StatelessWidget {
  const AudioWaveGlassCard({
    required this.onPlayNormal,
    required this.onPlaySlow,
    this.isBusy = false,
    this.title = 'استمع إلى المقطع',
    super.key,
  });

  final VoidCallback? onPlayNormal;
  final VoidCallback? onPlaySlow;
  final bool isBusy;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      glowColor: AppColors.primary,
      borderColor: AppColors.primary.withAlpha(72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: AppTypography.title),
          const SizedBox(height: 14),
          SizedBox(
            height: 58,
            child: CustomPaint(
              painter: _WavePainter(color: AppColors.primary),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _PlaybackAction(
                label: 'عادي',
                speedLabel: '1×',
                busy: isBusy,
                onPressed: onPlayNormal,
              ),
              const SizedBox(width: 18),
              _PlaybackAction(
                label: 'بطيء',
                speedLabel: '0.8×',
                busy: isBusy,
                onPressed: onPlaySlow,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaybackAction extends StatelessWidget {
  const _PlaybackAction({
    required this.label,
    required this.speedLabel,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final String speedLabel;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $speedLabel',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppAudioButton(
            onPressed: busy ? null : onPressed,
            semanticLabel: '$label $speedLabel',
            isBusy: busy,
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 5),
          Text('$label · $speedLabel', style: AppTypography.label),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({required this.color});

  final Color color;

  static const List<double> _levels = <double>[
    .22, .48, .72, .38, .86, .56, .94, .44, .68,
    .34, .78, .5, .9, .62, .4, .7, .3, .58,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(190)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final spacing = size.width / _levels.length;
    final centerY = size.height / 2;

    for (var index = 0; index < _levels.length; index += 1) {
      final height = size.height * _levels[index];
      final x = spacing * (index + .5);
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.color != color;
}
