import 'dart:async';

import '../../language/language_speech_profile.dart';
import 'domain/entities/audio_playback_result.dart';
import 'domain/entities/audio_playback_state.dart';
import 'domain/entities/audio_request.dart';
import 'domain/services/audio_catalog.dart';
import 'domain/services/i_audio_runtime.dart';
import 'domain/services/offline_tts_engine.dart';
import 'domain/services/recorded_audio_player.dart';

final class OfflineAudioRuntime implements IAudioRuntime {
  OfflineAudioRuntime({
    required this.speechProfile,
    required this.ttsEngine,
    this.catalog = const EmptyAudioCatalog(),
    this.recordedPlayer = const UnavailableRecordedAudioPlayer(),
    this.speechRateProvider,
  });

  final LanguageSpeechProfile speechProfile;
  final OfflineTtsEngine ttsEngine;
  final AudioCatalog catalog;
  final RecordedAudioPlayer recordedPlayer;
  final double Function()? speechRateProvider;

  final StreamController<AudioPlaybackState> _states =
      StreamController<AudioPlaybackState>.broadcast();
  Future<void> _tail = Future<void>.value();
  int _generation = 0;
  bool _closed = false;

  @override
  Stream<AudioPlaybackState> get playbackStateStream => _states.stream;

  @override
  Future<AudioPlaybackResult> play(AudioRequest request) async {
    if (_closed) {
      return const AudioPlaybackResult.unavailable('audio_runtime_closed');
    }
    if (!request.hasText) {
      return const AudioPlaybackResult.unavailable('audio_text_empty');
    }
    if (!_sameLanguage(request.languageCode, speechProfile.languageCode)) {
      return const AudioPlaybackResult.unavailable(
        'audio_language_profile_mismatch',
      );
    }

    final generation = ++_generation;
    final completer = Completer<AudioPlaybackResult>();
    final next = _tail.then((_) async {
      if (_closed || generation != _generation) {
        completer.complete(
          const AudioPlaybackResult.unavailable('audio_request_superseded'),
        );
        return;
      }
      _emit(AudioPlaybackState.loading);

      final conceptId = request.conceptId?.trim();
      if (conceptId != null && conceptId.isNotEmpty) {
        final asset = catalog.recordedAssetFor(
          conceptId: conceptId,
          variant: request.variant,
        );
        if (asset != null) {
          try {
            _emit(AudioPlaybackState.playing);
            if (await recordedPlayer.playAsset(asset)) {
              _emit(AudioPlaybackState.completed);
              _emit(AudioPlaybackState.idle);
              completer.complete(const AudioPlaybackResult.recorded());
              return;
            }
          } on Object {
            // A broken local asset may fall through to verified offline TTS.
          }
        }
      }

      if (_closed || generation != _generation) {
        _emit(AudioPlaybackState.idle);
        completer.complete(
          const AudioPlaybackResult.unavailable('audio_request_superseded'),
        );
        return;
      }

      final availability = await ttsEngine.probe(speechProfile);
      if (availability != OfflineTtsAvailability.ready) {
        _emit(AudioPlaybackState.error);
        completer.complete(
          const AudioPlaybackResult.unavailable(
            'offline_tts_voice_unavailable',
          ),
        );
        return;
      }

      _emit(AudioPlaybackState.playing);
      final spoken = await ttsEngine.speak(
        text: request.text.trim(),
        profile: speechProfile,
        rate: _resolveSpeechRate(request),
      );
      if (!spoken) {
        _emit(AudioPlaybackState.error);
        completer.complete(
          const AudioPlaybackResult.unavailable(
            'offline_tts_playback_failed',
          ),
        );
        return;
      }
      _emit(AudioPlaybackState.completed);
      _emit(AudioPlaybackState.idle);
      completer.complete(const AudioPlaybackResult.offlineTts());
    }).catchError((Object _) {
      if (!completer.isCompleted) {
        _emit(AudioPlaybackState.error);
        completer.complete(
          const AudioPlaybackResult.unavailable('audio_runtime_failure'),
        );
      }
    });
    _tail = next;
    return completer.future;
  }

  double _resolveSpeechRate(AudioRequest request) {
    try {
      final preferred = request.rate ??
          speechRateProvider?.call() ??
          speechProfile.defaultSpeechRate;
      return preferred.clamp(.1, 1.0).toDouble();
    } on Object {
      return speechProfile.defaultSpeechRate.clamp(.1, 1.0).toDouble();
    }
  }

  @override
  Future<void> stop() async {
    if (_closed) return;
    ++_generation;
    await Future.wait<void>(<Future<void>>[
      recordedPlayer.stop(),
      ttsEngine.stop(),
    ]);
    _emit(AudioPlaybackState.idle);
  }

  @override
  Future<void> shutdown() async {
    if (_closed) return;
    _closed = true;
    ++_generation;
    try {
      await Future.wait<void>(<Future<void>>[
        recordedPlayer.stop(),
        ttsEngine.stop(),
      ]);
      await _tail;
    } finally {
      await recordedPlayer.shutdown();
      await ttsEngine.shutdown();
      await _states.close();
    }
  }

  void _emit(AudioPlaybackState state) {
    if (!_closed && !_states.isClosed) {
      _states.add(state);
    }
  }

  bool _sameLanguage(String requested, String profile) {
    String base(String value) =>
        value.trim().toLowerCase().split(RegExp('[-_]')).first;
    return base(requested) == base(profile);
  }
}
