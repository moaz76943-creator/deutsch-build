import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../design_system/app_colors.dart';
import '../../../design_system/app_glass_card.dart';
import '../../../design_system/app_typography.dart';
import '../application/error_pattern_agent_notifier.dart';
import '../domain/error_pattern_models.dart';
import 'widgets/glass_diagnostic_card.dart';

class BlindSpotRadarScreen extends StatefulWidget {
  const BlindSpotRadarScreen({required this.notifier, super.key});

  final ErrorPatternAgentNotifier notifier;

  @override
  State<BlindSpotRadarScreen> createState() => _BlindSpotRadarScreenState();
}

class _BlindSpotRadarScreenState extends State<BlindSpotRadarScreen> {
  @override
  void initState() {
    super.initState();
    widget.notifier.initialize();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('رادار النقاط العمياء')),
          body: AnimatedBuilder(
            animation: widget.notifier,
            builder: (context, _) {
              final notifier = widget.notifier;
              final report = notifier.report;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  AppGlassCard(
                    glowColor: AppColors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'تشخيص لغوي تراكمي',
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'يعرض أنماط الإجابات المتكررة فقط، ولا يقيّم الشخصية أو القدرة العامة للمتعلم.',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: 12),
                        if (notifier.busy && !notifier.initialized)
                          const Center(child: CircularProgressIndicator())
                        else
                          SizedBox(
                            height: 250,
                            child: CustomPaint(
                              painter: _BlindSpotRadarPainter(report),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'سجل مصنّف: ${report.totalErrors} خطأ لغوي',
                          style: AppTypography.label,
                        ),
                      ],
                    ),
                  ),
                  if (notifier.lastError != null) ...[
                    const SizedBox(height: 12),
                    AppGlassCard(
                      glowColor: AppColors.tertiary,
                      child: Text(
                        notifier.lastError!,
                        style: AppTypography.body,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (report.isEmpty)
                    AppGlassCard(
                      child: Text(
                        'لا توجد أنماط متكررة كافية بعد. سيظهر التقرير بعد تسجيل أخطاء قابلة للتصنيف من البطاقات أو تمارين القواعد.',
                        style: AppTypography.body,
                      ),
                    )
                  else
                    for (final diagnostic in report.topBlindSpots) ...[
                      GlassDiagnosticCard(diagnostic: diagnostic),
                      const SizedBox(height: 12),
                    ],
                ],
              );
            },
          ),
        ),
      );
}

class _BlindSpotRadarPainter extends CustomPainter {
  const _BlindSpotRadarPainter(this.report);

  final BlindSpotReport report;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .34;
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.primary.withAlpha(55);
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.achievement.withAlpha(45);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = AppColors.achievement;

    for (final scale in <double>[.33, .66, 1]) {
      canvas.drawPath(_triangle(center, radius * scale), gridPaint);
    }
    final values = <ErrorPatternType, double>{
      for (final type in ErrorPatternType.values) type: 0,
      for (final item in report.topBlindSpots)
        item.type: item.frequency.clamp(0, 1).toDouble(),
    };
    final points = <Offset>[];
    for (var index = 0; index < ErrorPatternType.values.length; index++) {
      final angle = -math.pi / 2 + (index * 2 * math.pi / 3);
      final value = values[ErrorPatternType.values[index]] ?? 0;
      points.add(
        center +
            Offset(math.cos(angle), math.sin(angle)) * radius * value,
      );
      final axisEnd =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawLine(center, axisEnd, gridPaint);
    }
    if (points.length == 3) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, linePaint);
    }
  }

  Path _triangle(Offset center, double radius) {
    final path = Path();
    for (var index = 0; index < 3; index++) {
      final angle = -math.pi / 2 + (index * 2 * math.pi / 3);
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _BlindSpotRadarPainter oldDelegate) =>
      oldDelegate.report != report;
}
