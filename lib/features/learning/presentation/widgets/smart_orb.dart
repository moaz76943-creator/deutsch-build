import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/adaptive_glass_surface.dart';
import '../../../../core/theme/smart_orb_theme.dart';

enum SmartOrbFeedback {
  neutral,
  success,
  guidance,
  incorrect,
}

@immutable
final class SmartOrbDomainState {
  const SmartOrbDomainState({
    this.isSpeaking = false,
    this.feedback = SmartOrbFeedback.neutral,
  });

  final bool isSpeaking;
  final SmartOrbFeedback feedback;

  SmartOrbDomainState copyWith({
    bool? isSpeaking,
    SmartOrbFeedback? feedback,
  }) =>
      SmartOrbDomainState(
        isSpeaking: isSpeaking ?? this.isSpeaking,
        feedback: feedback ?? this.feedback,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartOrbDomainState &&
          other.isSpeaking == isSpeaking &&
          other.feedback == feedback;

  @override
  int get hashCode => Object.hash(isSpeaking, feedback);
}

class SmartOrb extends StatefulWidget {
  const SmartOrb({
    super.key,
    required this.state,
    this.size = 112,
    this.semanticsLabel = 'Interactive feedback core',
  }) : assert(size >= 64 && size <= 240);

  final SmartOrbDomainState state;
  final double size;
  final String semanticsLabel;

  @override
  State<SmartOrb> createState() => _SmartOrbState();
}

class _SmartOrbState extends State<SmartOrb>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _feedbackController;
  late final AnimationController _shakeController;
  late final Listenable _frameRepaint;

  bool _reduceMotion = false;
  bool _motionInitialized = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1120),
    );
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    _frameRepaint = Listenable.merge(<Listenable>[
      _pulseController,
      _feedbackController,
      _shakeController,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tokens = SmartOrbThemeTokens.of(context);
    _pulseController.duration = tokens.pulsePeriod;
    _feedbackController.duration = tokens.feedbackDuration;
    _shakeController.duration = tokens.shakeDuration;

    final motionChanged =
        !_motionInitialized || _reduceMotion != tokens.reduceMotion;
    _reduceMotion = tokens.reduceMotion;
    _motionInitialized = true;
    if (motionChanged) {
      _syncFrameState(forceFeedback: true);
    }
  }

  @override
  void didUpdateWidget(covariant SmartOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state == widget.state) return;

    if (oldWidget.state.isSpeaking != widget.state.isSpeaking) {
      _syncPulse();
    }
    if (oldWidget.state.feedback != widget.state.feedback) {
      _triggerFeedback();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _feedbackController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _syncFrameState({bool forceFeedback = false}) {
    _syncPulse();
    if (forceFeedback ||
        widget.state.feedback != SmartOrbFeedback.neutral) {
      _triggerFeedback();
    }
  }

  void _syncPulse() {
    if (_reduceMotion) {
      _pulseController
        ..stop()
        ..value = widget.state.isSpeaking ? 0.45 : 0;
      return;
    }

    if (widget.state.isSpeaking) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
      return;
    }

    if (_pulseController.value == 0) return;
    _pulseController.animateBack(
      0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _triggerFeedback() {
    final feedback = widget.state.feedback;
    if (feedback == SmartOrbFeedback.neutral) {
      _feedbackController
        ..stop()
        ..value = 0;
      _shakeController
        ..stop()
        ..value = 0;
      return;
    }

    if (_reduceMotion) {
      _feedbackController
        ..stop()
        ..value = 0.5;
      _shakeController
        ..stop()
        ..value = 0;
      return;
    }

    _feedbackController.forward(from: 0);
    if (feedback == SmartOrbFeedback.guidance ||
        feedback == SmartOrbFeedback.incorrect) {
      _shakeController.forward(from: 0);
    } else {
      _shakeController
        ..stop()
        ..value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SmartOrbThemeTokens.of(context);

    return Semantics(
      image: true,
      label: widget.semanticsLabel,
      value: _semanticValue(widget.state),
      child: SizedBox.square(
        dimension: widget.size,
        child: AdaptiveGlassSurface(
          padding: EdgeInsets.zero,
          borderRadius: widget.size / 2,
          blurSigma: tokens.glassBlurSigma,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _SmartOrbPainter(
                domainState: widget.state,
                palette: tokens.palette,
                pulse: _pulseController,
                feedback: _feedbackController,
                shake: _shakeController,
                repaint: _frameRepaint,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }

  static String _semanticValue(SmartOrbDomainState state) {
    final feedback = switch (state.feedback) {
      SmartOrbFeedback.neutral => 'neutral',
      SmartOrbFeedback.success => 'success',
      SmartOrbFeedback.guidance => 'guidance',
      SmartOrbFeedback.incorrect => 'incorrect answer',
    };
    return state.isSpeaking ? '$feedback, speaking' : feedback;
  }
}

final class _SmartOrbPainter extends CustomPainter {
  _SmartOrbPainter({
    required this.domainState,
    required this.palette,
    required this.pulse,
    required this.feedback,
    required this.shake,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final SmartOrbDomainState domainState;
  final SmartOrbPalette palette;
  final Animation<double> pulse;
  final Animation<double> feedback;
  final Animation<double> shake;

  @override
  void paint(Canvas canvas, Size size) {
    final minSide = math.min(size.width, size.height);
    if (minSide <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final pulseValue = domainState.isSpeaking
        ? pulse.value.clamp(0.0, 1.0).toDouble()
        : 0.0;
    final feedbackEnvelope =
        domainState.feedback == SmartOrbFeedback.neutral
            ? 0.0
            : 0.16 +
                math.sin(math.pi * feedback.value).abs() * 0.84;
    final activeColor = _activeColor();
    final shakeOffset = _shakeOffset(minSide);

    canvas.save();
    canvas.translate(shakeOffset, 0);

    final radius = minSide * (0.292 + pulseValue * 0.018);
    final haloRadius =
        radius * (1.48 + pulseValue * 0.08 + feedbackEnvelope * 0.05);
    final haloRect = Rect.fromCircle(
      center: center,
      radius: haloRadius,
    );
    final haloOpacity =
        0.10 + pulseValue * 0.10 + feedbackEnvelope * 0.24;

    canvas.drawCircle(
      center,
      haloRadius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            activeColor.withValues(alpha: haloOpacity),
            activeColor.withValues(alpha: haloOpacity * 0.28),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.58, 1],
        ).createShader(haloRect),
    );

    final orbRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.34, -0.38),
          radius: 1.05,
          colors: <Color>[
            palette.glassHighlight.withValues(alpha: 0.86),
            activeColor.withValues(
              alpha: 0.34 + feedbackEnvelope * 0.18,
            ),
            palette.core.withValues(alpha: 0.24),
          ],
          stops: const <double>[0, 0.46, 1],
        ).createShader(orbRect),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, minSide * 0.012)
        ..color = palette.outline.withValues(alpha: 0.72),
    );

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, minSide * 0.013)
      ..color = activeColor.withValues(
        alpha: 0.46 + feedbackEnvelope * 0.30,
      );
    final orbitRect = Rect.fromCircle(
      center: center,
      radius: radius * 0.79,
    );
    final phase = pulseValue * 0.18;
    canvas.drawArc(
      orbitRect,
      -0.88 + phase,
      math.pi * 1.18,
      false,
      orbitPaint,
    );
    orbitPaint.strokeWidth *= 0.72;
    canvas.drawArc(
      orbitRect,
      2.20 + phase,
      math.pi * 0.72,
      false,
      orbitPaint,
    );

    final polygonRadius = radius * 0.50;
    final polygon = _regularPolygon(
      center: center,
      radius: polygonRadius,
      sides: 6,
      rotation: math.pi / 6 + pulseValue * 0.04,
    );
    canvas.drawPath(
      polygon,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, minSide * 0.010)
        ..color = activeColor.withValues(
          alpha: 0.56 + feedbackEnvelope * 0.26,
        ),
    );

    final diamond = _regularPolygon(
      center: center,
      radius: radius * 0.25,
      sides: 4,
      rotation: math.pi / 4,
    );
    canvas.drawPath(
      diamond,
      Paint()
        ..style = PaintingStyle.fill
        ..color = activeColor.withValues(
          alpha: 0.16 + feedbackEnvelope * 0.18,
        ),
    );

    final pulseRingRadius = radius * (1.08 + pulseValue * 0.14);
    canvas.drawCircle(
      center,
      pulseRingRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, minSide * 0.008)
        ..color = activeColor.withValues(
          alpha: domainState.isSpeaking
              ? 0.18 + pulseValue * 0.34
              : 0.10 + feedbackEnvelope * 0.12,
        ),
    );

    canvas.restore();
  }

  Color _activeColor() => switch (domainState.feedback) {
        SmartOrbFeedback.neutral => palette.core,
        SmartOrbFeedback.success => palette.success,
        SmartOrbFeedback.guidance => palette.guidance,
        SmartOrbFeedback.incorrect => palette.incorrect,
      };

  double _shakeOffset(double minSide) {
    if (domainState.feedback != SmartOrbFeedback.guidance &&
        domainState.feedback != SmartOrbFeedback.incorrect) {
      return 0;
    }
    final progress = shake.value.clamp(0.0, 1.0).toDouble();
    final envelope = 1 - progress;
    return math.sin(progress * math.pi * 6) *
        minSide *
        0.026 *
        envelope;
  }

  static Path _regularPolygon({
    required Offset center,
    required double radius,
    required int sides,
    required double rotation,
  }) {
    final path = Path();
    for (var index = 0; index < sides; index += 1) {
      final angle =
          rotation + (math.pi * 2 * index / sides);
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _SmartOrbPainter oldDelegate) =>
      oldDelegate.domainState != domainState ||
      oldDelegate.palette.core != palette.core ||
      oldDelegate.palette.success != palette.success ||
      oldDelegate.palette.guidance != palette.guidance ||
      oldDelegate.palette.incorrect != palette.incorrect ||
      oldDelegate.palette.glassHighlight !=
          palette.glassHighlight ||
      oldDelegate.palette.outline != palette.outline;
}
