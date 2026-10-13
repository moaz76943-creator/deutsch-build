import 'dart:async';
import 'dart:collection';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutsch_bilarabi/core/audio/audio_pool_policy.dart';
import 'package:deutsch_bilarabi/core/audio/audio_generation_tracker.dart';

class _AudioRequest {
  final String text;
  final String locale;
  final double speechRate;
  final Completer<void> completer;

  _AudioRequest({
    required this.text,
    required this.locale,
    required this.speechRate,
    required this.completer,
  });
}

class OfflineAudioPool {
  static final OfflineAudioPool _instance = OfflineAudioPool._internal();
  factory OfflineAudioPool() => _instance;
  OfflineAudioPool._internal() {
    // Disable network requests on Android if possible, or strictly enforce via check
  }

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String _activeLocale = '';
  double _activeSpeechRate = -1.0;

  final AudioPoolPolicy _policy = const AudioPoolPolicy();
  final Queue<_AudioRequest> _queue = Queue<_AudioRequest>();
  final AudioGenerationTracker _generationTracker = AudioGenerationTracker();

  Future<bool> verifyOfflineCapability(String bcp47) async {
    try {
      final isAvailable = await _tts.isLanguageAvailable(bcp47);
      return isAvailable == true;
    } catch (_) {
      return false;
    }
  }

  void _processQueue() async {
    if (_isPlaying || _queue.isEmpty) return;

    _isPlaying = true;
    final request = _queue.removeFirst();
    final int currentGeneration = _generationTracker.currentGeneration;

    try {
      if (_activeLocale != request.locale) {
        await _tts.setLanguage(request.locale);
        _activeLocale = request.locale;
      }
      if (_activeSpeechRate != request.speechRate) {
        await _tts.setSpeechRate(request.speechRate);
        _activeSpeechRate = request.speechRate;
      }

      await _tts.awaitSpeakCompletion(true);
      if (_generationTracker.isCurrent(currentGeneration)) {
        await _tts.speak(request.text);
      }
      if (!request.completer.isCompleted) {
        request.completer.complete();
      }
    } catch (e) {
      if (!request.completer.isCompleted) {
        request.completer.completeError(e);
      }
    } finally {
      _isPlaying = false;
      if (_generationTracker.isCurrent(currentGeneration)) {
        _processQueue();
      }
    }
  }

  Future<void> playWord(
    String text, {
    String locale = 'de-DE',
    double speechRate = 0.45,
  }) async {
    if (!_policy.canAllocate(_queue.length + (_isPlaying ? 1 : 0))) {
      // Bounded queue: drop oldest or reject. Rejecting to keep bounded.
      _queue.clear();
      await stop();
    }

    final completer = Completer<void>();
    _queue.add(_AudioRequest(
      text: text,
      locale: locale,
      speechRate: speechRate,
      completer: completer,
    ));

    _processQueue();
    return completer.future;
  }

  Future<void> stop() async {
    _generationTracker.reset();
    _queue.clear();
    try {
      await _tts.stop();
    } catch (_) {}
    _isPlaying = false;
  }

  void dispose() {
    stop();
  }
}
