import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/settings/speech_rate_settings.dart';

class OfflineSpeechRateSelector extends StatelessWidget {
  const OfflineSpeechRateSelector({
    super.key,
    required this.controller,
    this.onPreview,
  });

  final SpeechRateSettingsController controller;
  final Future<void> Function(double speedMultiplier)? onPreview;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final preset in SpeechRatePreset.values)
              ChoiceChip(
                label: Text(preset.label),
                selected: controller.preset == preset,
                onSelected: (selected) {
                  if (selected) controller.setPreset(preset);
                },
              ),
            if (onPreview != null)
              IconButton(
                tooltip: 'Preview',
                onPressed: () => unawaited(
                  onPreview!(controller.speedMultiplier),
                ),
                icon: const Icon(Icons.volume_up_outlined),
              ),
          ],
        );
      },
    );
  }
}
