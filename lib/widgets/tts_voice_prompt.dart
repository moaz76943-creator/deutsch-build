import 'dart:async';

import 'package:flutter/material.dart';

import '../services/tts_service.dart';

/// A compact notification shown only when a requested Android voice is absent.
class TtsVoicePrompt extends StatelessWidget {
  const TtsVoicePrompt({super.key, required this.languageName});

  final String languageName;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Voice data for $languageName is not installed on your phone.',
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Check the requested voice and show a non-blocking SnackBar if missing.
  ///
  /// Call after a voice-availability check is needed; this method never
  /// requests a download without a user tapping "Download Voice".
  static Future<void> showIfMissing(
    BuildContext context, {
    required String languageName,
    required String languageTag,
    TtsService? service,
  }) async {
    final voiceService = service ?? TtsService();
    bool installed;
    try {
      installed = await voiceService.isLanguageVoiceInstalled(languageTag);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to check installed voice data on this device.'),
        ),
      );
      return;
    }

    if (!context.mounted || installed) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: TtsVoicePrompt(languageName: languageName),
        action: SnackBarAction(
          label: 'Download Voice',
          onPressed: () {
            unawaited(_openInstaller(messenger, voiceService));
          },
        ),
      ),
    );
  }

  static Future<void> _openInstaller(
    ScaffoldMessengerState messenger,
    TtsService voiceService,
  ) async {
    try {
      await voiceService.openSystemTtsInstallSettings();
    } catch (_) {
      if (!messenger.mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the voice installer. '
            'Open Android Settings > Text-to-speech output > Install voice data.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
