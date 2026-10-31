import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/adaptive_glass_surface.dart';
import '../application/local_learning_recovery_controller.dart';
import '../domain/local_learning_recovery.dart';
import 'widgets/smart_orb.dart';

typedef LocalLearningRecoveryPromptBuilder = Widget Function(
  BuildContext context,
  LocalLearningRecoveryPlan plan,
);

/// Observes app lifecycle only while the learning surface is mounted.
///
/// A resume event triggers an async canonical SRS read; animation frames never
/// perform SQLite, worker, EventBus, JSON, or network work.
class LocalLearningRecoveryLifecycleHost extends StatefulWidget {
  const LocalLearningRecoveryLifecycleHost({
    super.key,
    required this.controller,
    required this.child,
    required this.promptBuilder,
    this.checkImmediately = true,
  });

  final LocalLearningRecoveryController controller;
  final Widget child;
  final LocalLearningRecoveryPromptBuilder promptBuilder;
  final bool checkImmediately;

  @override
  State<LocalLearningRecoveryLifecycleHost> createState() =>
      _LocalLearningRecoveryLifecycleHostState();
}

class _LocalLearningRecoveryLifecycleHostState
    extends State<LocalLearningRecoveryLifecycleHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.checkImmediately) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(widget.controller.refreshOnReturn());
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.controller.refreshOnReturn());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      child: widget.child,
      builder: (context, child) {
        final plan = widget.controller.plan;
        return Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            if (child != null) child,
            if (plan != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  minimum: const EdgeInsets.all(12),
                  child: widget.promptBuilder(context, plan),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Calm, non-modal recovery affordance linked to the existing Smart Orb.
///
/// No punitive engagement mechanic, notification channel, or custom animation is
/// introduced. The Smart Orb's existing reduced-motion behavior remains the
/// sole motion policy for this prompt.
class LocalLearningRecoveryPrompt extends StatelessWidget {
  const LocalLearningRecoveryPrompt({
    super.key,
    required this.plan,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.dismissLabel,
    required this.onStart,
    required this.onDismiss,
    this.orbSemanticsLabel = 'Learning recovery guidance',
  });

  final LocalLearningRecoveryPlan plan;
  final String title;
  final String message;
  final String actionLabel;
  final String dismissLabel;
  final VoidCallback onStart;
  final VoidCallback onDismiss;
  final String orbSemanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: AdaptiveGlassSurface(
        padding: const EdgeInsets.all(14),
        borderRadius: 22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SmartOrb(
              size: 72,
              semanticsLabel: orbSemanticsLabel,
              state: const SmartOrbDomainState(
                feedback: SmartOrbFeedback.guidance,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      FilledButton.tonal(
                        onPressed: onStart,
                        child: Text(actionLabel),
                      ),
                      TextButton(
                        onPressed: onDismiss,
                        child: Text(dismissLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
