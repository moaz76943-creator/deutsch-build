import 'dart:async';

import 'package:flutter/material.dart';

enum BreathingPhase { inhale, holdIn, exhale, holdOut }

class MicroBreaksScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const MicroBreaksScreen({super.key, this.onComplete});

  @override
  State<MicroBreaksScreen> createState() => _MicroBreaksScreenState();
}

class _MicroBreaksScreenState extends State<MicroBreaksScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _cycleCount = 0;
  final int _maxCycles = 3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4 seconds for inhale
    );

    _controller.addStatusListener(_handleAnimationStatus);
    _controller.forward();
  }

  Timer? _timer;

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (_currentPhase == BreathingPhase.inhale) {
        setState(() => _currentPhase = BreathingPhase.holdIn);
        _timer = Timer(const Duration(seconds: 4), () {
          if (!mounted) return;
          setState(() => _currentPhase = BreathingPhase.exhale);
          _controller.duration = const Duration(
            seconds: 4,
          ); // 4 seconds for exhale
          _controller.reverse();
        });
      }
    } else if (status == AnimationStatus.dismissed) {
      if (_currentPhase == BreathingPhase.exhale) {
        setState(() => _currentPhase = BreathingPhase.holdOut);
        _timer = Timer(const Duration(seconds: 4), () {
          if (!mounted) return;
          _cycleCount++;
          if (_cycleCount >= _maxCycles) {
            if (widget.onComplete != null) {
              widget.onComplete!();
            } else {
              Navigator.of(context).pop();
            }
          } else {
            setState(() => _currentPhase = BreathingPhase.inhale);
            _controller.duration = const Duration(
              seconds: 4,
            ); // 4 seconds for inhale
            _controller.forward();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  String get _promptText {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Breathe In...';
      case BreathingPhase.holdIn:
        return 'Hold...';
      case BreathingPhase.exhale:
        return 'Breathe Out...';
      case BreathingPhase.holdOut:
        return 'Relax...';
    }
  }

  IconData get _phaseIcon {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return Icons.air;
      case BreathingPhase.holdIn:
        return Icons.pause_circle_outline;
      case BreathingPhase.exhale:
        return Icons.water_drop_outlined;
      case BreathingPhase.holdOut:
        return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Micro-Break',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w300, letterSpacing: 2.0),
              ),
              const SizedBox(height: 16),
              Text(
                'Relax your eyes. Follow the rhythm.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 64),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // _controller.value goes from 0.0 to 1.0 on forward (inhale)
                  // and 1.0 to 0.0 on reverse (exhale).
                  // Hold states maintain the value (1.0 or 0.0).
                  final scale = 0.5 + (_controller.value * 0.5);
                  final opacity = 0.3 + (_controller.value * 0.7);

                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: opacity * 0.2),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: opacity),
                        width: 2.0,
                      ),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: opacity * 0.5),
                          ),
                          child: Center(
                            child: Icon(
                              _phaseIcon,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 64),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _promptText,
                  key: ValueKey<BreathingPhase>(_currentPhase),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Cycle ${_cycleCount + 1} of $_maxCycles',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
              const SizedBox(height: 48),
              TextButton(
                onPressed: () {
                  if (widget.onComplete != null) {
                    widget.onComplete!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Skip Break'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
