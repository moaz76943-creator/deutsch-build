import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_result.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_request.dart';
import 'package:deutsch_bilarabi/features/audio/domain/services/audio_catalog.dart';
import 'package:deutsch_bilarabi/features/audio/domain/services/offline_tts_engine.dart';
import 'package:deutsch_bilarabi/features/audio/domain/services/recorded_audio_player.dart';
import 'package:deutsch_bilarabi/features/audio/offline_audio_runtime.dart';
import 'package:deutsch_bilarabi/language/german/german_speech_profile.dart';
import 'package:deutsch_bilarabi/language/language_speech_profile.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Catalog implements AudioCatalog {
  const _Catalog(this.asset);
  final String? asset;

  @override
  String? recordedAssetFor({
    required String conceptId,
    required AudioVariant variant,
  }) => asset;
}

final class _Player implements RecordedAudioPlayer {
  _Player({required this.result});
  final bool result;
  int plays = 0;

  @override
  Future<bool> playAsset(String assetPath) async {
    plays++;
    return result;
  }

  @override
  Future<void> shutdown() async {}

  @override
  Future<void> stop() async {}
}

final class _Tts implements OfflineTtsEngine {
  _Tts({required this.availability, this.speakResult = true});
  final OfflineTtsAvailability availability;
  final bool speakResult;
  int speaks = 0;

  @override
  Future<OfflineTtsAvailability> probe(LanguageSpeechProfile profile) async =>
      availability;

  @override
  Future<bool> speak({
    required String text,
    required LanguageSpeechProfile profile,
    required double rate,
  }) async {
    speaks++;
    return speakResult;
  }

  @override
  Future<void> shutdown() async {}

  @override
  Future<void> stop() async {}
}

void main() {
  test('recorded asset wins over TTS when available', () async {
    final player = _Player(result: true);
    final tts = _Tts(availability: OfflineTtsAvailability.ready);
    final runtime = OfflineAudioRuntime(
      speechProfile: const GermanSpeechProfile(),
      ttsEngine: tts,
      catalog: const _Catalog('content/german/audio/de-1.mp3'),
      recordedPlayer: player,
    );

    final result = await runtime.play(
      const AudioRequest(
        conceptId: 'de-1',
        text: 'Haus',
        languageCode: 'de',
      ),
    );

    expect(result.source, AudioPlaybackSource.recorded);
    expect(player.plays, 1);
    expect(tts.speaks, 0);
    await runtime.shutdown();
  });

  test('failed recorded asset falls back only to offline TTS', () async {
    final player = _Player(result: false);
    final tts = _Tts(availability: OfflineTtsAvailability.ready);
    final runtime = OfflineAudioRuntime(
      speechProfile: const GermanSpeechProfile(),
      ttsEngine: tts,
      catalog: const _Catalog('content/german/audio/de-1.mp3'),
      recordedPlayer: player,
    );

    final result = await runtime.play(
      const AudioRequest(
        conceptId: 'de-1',
        text: 'Haus',
        languageCode: 'de-DE',
      ),
    );

    expect(result.source, AudioPlaybackSource.offlineTts);
    expect(tts.speaks, 1);
    await runtime.shutdown();
  });

  test('no offline voice fails explicitly without pretending playback', () async {
    final tts = _Tts(availability: OfflineTtsAvailability.unavailable);
    final runtime = OfflineAudioRuntime(
      speechProfile: const GermanSpeechProfile(),
      ttsEngine: tts,
    );

    final result = await runtime.play(
      const AudioRequest(text: 'Haus', languageCode: 'de'),
    );

    expect(result.source, AudioPlaybackSource.unavailable);
    expect(result.reason, 'offline_tts_voice_unavailable');
    expect(tts.speaks, 0);
    await runtime.shutdown();
  });

  test('language mismatch never pivots through another language', () async {
    final tts = _Tts(availability: OfflineTtsAvailability.ready);
    final runtime = OfflineAudioRuntime(
      speechProfile: const GermanSpeechProfile(),
      ttsEngine: tts,
    );

    final result = await runtime.play(
      const AudioRequest(text: 'house', languageCode: 'en'),
    );

    expect(result.source, AudioPlaybackSource.unavailable);
    expect(result.reason, 'audio_language_profile_mismatch');
    expect(tts.speaks, 0);
    await runtime.shutdown();
  });
}
