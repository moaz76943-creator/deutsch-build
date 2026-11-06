import 'dart:async';

import 'package:flutter/material.dart';

import '../core/audio/offline_audio_capability.dart';
import 'language_pack_manager.dart';
import 'tts_service.dart';

typedef VoiceAvailabilityProbe = Future<bool> Function(String languageTag);
typedef OfflineSpeechPlayback = Future<bool> Function(
  String text,
  String languageTag,
);

/// A bounded offline-only facade for the system speech engine.
/// Unsupported BCP-47 codes and uninstalled voices never fall back to a
/// different spoken language or initiate a download.
class HybridAudioService {
  HybridAudioService({
    TtsService? ttsService,
    VoiceAvailabilityProbe? voiceProbe,
    OfflineSpeechPlayback? speechPlayback,
    this.voiceTimeout = const Duration(seconds: 5),
    this.playbackTimeout = const Duration(seconds: 7),
  })  : _tts = ttsService ?? TtsService(),
        _voiceProbe = voiceProbe,
        _speechPlayback = speechPlayback;

  final TtsService _tts;
  final VoiceAvailabilityProbe? _voiceProbe;
  final OfflineSpeechPlayback? _speechPlayback;
  final Duration voiceTimeout;
  final Duration playbackTimeout;
  bool _busy = false;

  static String fallbackMessage(String languageCode, {String? ipa}) {
    final languageName = LanguagePackManager.getLanguageName(languageCode);
    final transcription = ipa?.trim() ?? '';
    final pronunciation = transcription.isEmpty
        ? 'IPA transcription is not available.'
        : 'Pronounce using IPA: /${transcription.replaceAll('/', '')}/';
    return 'Audio not available for $languageName. $pronunciation';
  }

  /// Does not retain BuildContext across an await; checks mounted before UI.
  /// A callback allows the same behavior in non-widget tests.
  Future<bool> play({
    required String text,
    required String languageCode,
    String? ipa,
    BuildContext? context,
    void Function(String message)? onUnavailable,
  }) async {
    if (text.trim().isEmpty) return false;
    final tag = OfflineAudioCapability.getFallbackLocale(languageCode);
    void unavailable() {
      final message = fallbackMessage(languageCode, ipa: ipa);
      try {
        onUnavailable?.call(message);
      } catch (_) {
        // Fallback presentation is always best effort.
      }
      if (context != null && context.mounted) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.hideCurrentSnackBar();
        messenger?.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message, maxLines: 4, overflow: TextOverflow.ellipsis),
        ));
      }
    }

    if (tag == null || tag.isEmpty || _busy) {
      unavailable();
      return false;
    }
    _busy = true;
    try {
      final probe = _voiceProbe ?? _tts.isVoiceAvailable;
      final available = await probe(languageCode)
          .timeout(voiceTimeout, onTimeout: () => false)
          .catchError((Object _) => false);
      if (!available) {
        unavailable();
        return false;
      }
      final speaker = _speechPlayback ??
          (String value, String locale) =>
              _tts.speak(value, languageCode: locale);
      final success = await speaker(text, languageCode)
          .timeout(playbackTimeout, onTimeout: () => false)
          .catchError((Object _) => false);
      if (!success) unavailable();
      return success;
    } catch (_) {
      unavailable();
      return false;
    } finally {
      _busy = false;
    }
  }

  /// Explicit screen-facing alias; preserve existing play() callers.
  Future<bool> playAudio({
    required String text,
    required String languageCode,
    String? ipa,
    BuildContext? context,
    void Function(String message)? onUnavailable,
  }) =>
      play(
        text: text,
        languageCode: languageCode,
        ipa: ipa,
        context: context,
        onUnavailable: onUnavailable,
      );

  /// Bounded stop to avoid waiting forever on a broken platform channel.
  Future<void> stop() async {
    try {
      await _tts.stop().timeout(playbackTimeout);
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _tts.dispose().timeout(playbackTimeout);
    } catch (_) {}
  }
}
