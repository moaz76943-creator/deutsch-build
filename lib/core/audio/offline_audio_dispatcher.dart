import 'dart:async';
import 'dart:collection';
import 'package:deutsch_bilarabi/core/audio/offline_audio_pool.dart';

class _AudioRequest {
  final String text;
  final String locale;
  final double speechRate;
  final int token;
  final Completer<bool> completer;

  _AudioRequest(this.text, this.locale, this.speechRate, this.token, this.completer);
}

class OfflineAudioDispatcher {
  static int _currentGenerationToken = 0;
  static bool _isPlaying = false;
  static bool get isPlaying => _isPlaying;

  static final Queue<_AudioRequest> _queue = Queue<_AudioRequest>();
  static const int _maxQueueSize = 5;
  static bool _isProcessingQueue = false;

  static Future<bool> speakText({
    required String text,
    required String bcp47Locale,
    double speechRate = 0.9,
  }) async {
    final int thisToken = ++_currentGenerationToken;
    final completer = Completer<bool>();

    if (_queue.length >= _maxQueueSize) {
      final dropped = _queue.removeFirst();
      if (!dropped.completer.isCompleted) {
        dropped.completer.complete(false);
      }
    }

    _queue.addLast(_AudioRequest(text, bcp47Locale, speechRate * 0.5, thisToken, completer));

    if (!_isProcessingQueue) {
      _processQueue();
    }

    return completer.future;
  }

  static Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;
    _isPlaying = true;

    try {
      while (_queue.isNotEmpty) {
        final request = _queue.removeFirst();

        if (request.token != _currentGenerationToken) {
          if (!request.completer.isCompleted) request.completer.complete(false);
          continue;
        }

        try {
          await OfflineAudioPool().playWord(
            request.text,
            locale: request.locale,
            speechRate: request.speechRate,
          );
          if (request.token == _currentGenerationToken) {
            if (!request.completer.isCompleted) request.completer.complete(true);
          } else {
            if (!request.completer.isCompleted) request.completer.complete(false);
          }
        } catch (_) {
          if (!request.completer.isCompleted) request.completer.complete(false);
        }
      }
    } finally {
      if (_queue.isEmpty) {
        _isPlaying = false;
      }
      _isProcessingQueue = false;
    }
  }

  static void stopCurrentAudio() {
    _currentGenerationToken++;
    while (_queue.isNotEmpty) {
      final req = _queue.removeFirst();
      if (!req.completer.isCompleted) req.completer.complete(false);
    }
    _isPlaying = false;
    OfflineAudioPool().stop();
  }
}
