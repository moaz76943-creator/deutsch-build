import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/audio/offline_tts_engine.dart';

void main() {
  group('OfflineTtsEngine Tiered Fallback Tests', () {
    late Directory tempVoiceDir;

    setUp(() async {
      tempVoiceDir = await Directory.systemTemp.createTemp('voice_pack_test_');
    });

    tearDown(() async {
      if (await tempVoiceDir.exists()) {
        await tempVoiceDir.delete(recursive: true);
      }
    });

    test('Plays from downloaded voice pack when valid file is present', () async {
      final audioFile = File('${tempVoiceDir.path}/de_hallo.mp3');
      await audioFile.writeAsBytes([0xFF, 0xFB, 0x90, 0x44]); // Dummy MP3 bytes

      final engine = OfflineTtsEngine(
        localVoicePackDir: tempVoiceDir,
        isSystemTtsAvailable: true,
      );

      final result = await engine.playPronunciation(
        text: 'Hallo',
        languageCode: 'de',
        localAudioFileName: 'de_hallo.mp3',
      );

      expect(result.sourceType, equals(AudioSourceType.downloadedVoicePack));
      expect(result.isPlayed, isTrue);
    });

    test('Falls back to system TTS when voice pack file is absent', () async {
      final engine = OfflineTtsEngine(
        localVoicePackDir: tempVoiceDir,
        isSystemTtsAvailable: true,
      );

      final result = await engine.playPronunciation(
        text: 'Guten Tag',
        languageCode: 'de',
        localAudioFileName: 'nonexistent.mp3',
      );

      expect(result.sourceType, equals(AudioSourceType.systemTtsEngine));
      expect(result.isPlayed, isTrue);
    });

    test('Falls back gracefully to silent mode when both pack and system TTS are unavailable', () async {
      final engine = OfflineTtsEngine(
        localVoicePackDir: null,
        isSystemTtsAvailable: false,
      );

      final result = await engine.playPronunciation(
        text: 'Danke',
        languageCode: 'de',
      );

      expect(result.sourceType, equals(AudioSourceType.silentFallback));
      expect(result.isPlayed, isFalse);
    });
  });
}
