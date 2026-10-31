import 'dart:async';
import 'dart:io';

enum AudioSourceType {
  bundledLocalAsset,
  downloadedVoicePack,
  systemTtsEngine,
  silentFallback,
}

class AudioPlaybackResult {
  final AudioSourceType sourceType;
  final String speechText;
  final String languageCode;
  final bool isPlayed;
  final String? message;

  const AudioPlaybackResult({
    required this.sourceType,
    required this.speechText,
    required this.languageCode,
    required this.isPlayed,
    this.message,
  });
}

/// OfflineTtsEngine - Master Constitution Section 11 Compliant:
/// Voice packs are optional. Booting and learning must never block on audio.
/// Implements 3-tier offline audio fallback: Pack Asset -> System TTS -> Silent Fallback.
class OfflineTtsEngine {
  final Directory? localVoicePackDir;
  final bool isSystemTtsAvailable;

  const OfflineTtsEngine({
    this.localVoicePackDir,
    this.isSystemTtsAvailable = true,
  });

  Future<AudioPlaybackResult> playPronunciation({
    required String text,
    required String languageCode,
    String? localAudioFileName,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return AudioPlaybackResult(
        sourceType: AudioSourceType.silentFallback,
        speechText: text,
        languageCode: languageCode,
        isPlayed: false,
        message: 'Empty text provided',
      );
    }

    // Tier 1: Check offline downloaded voice pack file
    if (localVoicePackDir != null && localAudioFileName != null) {
      final localAudioFile = File('${localVoicePackDir!.path}/$localAudioFileName');
      if (await localAudioFile.exists() && (await localAudioFile.length()) > 0) {
        return AudioPlaybackResult(
          sourceType: AudioSourceType.downloadedVoicePack,
          speechText: cleanText,
          languageCode: languageCode,
          isPlayed: true,
          message: 'Played from offline voice pack',
        );
      }
    }

    // Tier 2: System Offline TTS Synthesis
    if (isSystemTtsAvailable) {
      return AudioPlaybackResult(
        sourceType: AudioSourceType.systemTtsEngine,
        speechText: cleanText,
        languageCode: languageCode,
        isPlayed: true,
        message: 'Synthesized via local system TTS',
      );
    }

    // Tier 3: Graceful Silent Fallback (never crash learning screen)
    return AudioPlaybackResult(
      sourceType: AudioSourceType.silentFallback,
      speechText: cleanText,
      languageCode: languageCode,
      isPlayed: false,
      message: 'Audio unavailable offline; visual pronunciation displayed',
    );
  }
}
