import 'dart:async';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'offline_audio_capability.dart';

class _AudioRequest {
  final String text;
  final String locale;
  final double speechRate;
  final Completer<bool> completer;

  _AudioRequest(this.text, this.locale, this.speechRate, this.completer);
}

class OfflineAudioPool with WidgetsBindingObserver {
  static final OfflineAudioPool _instance = OfflineAudioPool._internal();
  factory OfflineAudioPool() => _instance;

  OfflineAudioPool._internal() {
    WidgetsBinding.instance.addObserver(this);
    _initTts();
  }

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String _activeLocale = '';
  double _activeSpeechRate = -1.0;

  int _pairGenerationToken = 0;
  final int maxQueueSize = 5;
  final Queue<_AudioRequest> _requestQueue = Queue<_AudioRequest>();
  bool _isProcessingQueue = false;

  void _initTts() {
    // We enable deterministic playback completion tracking for the queue using awaitSpeakCompletion.
    _tts.awaitSpeakCompletion(true);

    _tts.setCompletionHandler(() {
      _isPlaying = false;
    });
    _tts.setErrorHandler((msg) {
      _isPlaying = false;
    });
    _tts.setCancelHandler(() {
      _isPlaying = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      stop();
    }
  }

  void markPairChange() {
    _pairGenerationToken++;
    stop();
    _clearQueue();
  }

  void _clearQueue() {
    while (_requestQueue.isNotEmpty) {
      final req = _requestQueue.removeFirst();
      if (!req.completer.isCompleted) {
        req.completer.complete(false); // Reject stale callback
      }
    }
  }

  Future<bool> playWord(
    String text, {
    String locale = 'de-DE',
    double speechRate = 0.45,
  }) async {
    final effectiveLocale = OfflineAudioCapability.getFallbackLocale(locale);
    if (effectiveLocale == null) {
      // Missing voice handling, never fall back silently
      return false;
    }

    final completer = Completer<bool>();
    final request = _AudioRequest(text, effectiveLocale, speechRate, completer);

    if (_requestQueue.length >= maxQueueSize) {
      final oldReq = _requestQueue.removeFirst();
      if (!oldReq.completer.isCompleted) {
        oldReq.completer.complete(false);
      }
    }

    _requestQueue.add(request);
    _processQueue();

    return completer.future;
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue || _requestQueue.isEmpty) return;
    _isProcessingQueue = true;

    while (_requestQueue.isNotEmpty) {
      final currentGeneration = _pairGenerationToken;
      final req = _requestQueue.removeFirst();

      try {
        await _tts.stop();
        _isPlaying = true;

        if (_activeLocale != req.locale) {
          final isLangAvailable = await _tts.setLanguage(req.locale);
          if (isLangAvailable == 0 || isLangAvailable == false) {
            _isPlaying = false;
            if (!req.completer.isCompleted) req.completer.complete(false);
            continue; // Skip this word, it doesn't have a local speech engine
          }
          _activeLocale = req.locale;
        }

        if (_activeSpeechRate != req.speechRate) {
          await _tts.setSpeechRate(req.speechRate);
          _activeSpeechRate = req.speechRate;
        }

        if (currentGeneration != _pairGenerationToken) {
          _isPlaying = false;
          if (!req.completer.isCompleted) req.completer.complete(false);
          continue;
        }

        await _tts.speak(req.text);

        if (currentGeneration == _pairGenerationToken) {
          if (!req.completer.isCompleted) req.completer.complete(true);
        } else {
          if (!req.completer.isCompleted) req.completer.complete(false);
        }
      } catch (_) {
        if (!req.completer.isCompleted) req.completer.complete(false);
      } finally {
        _isPlaying = false;
      }
    }

    _isProcessingQueue = false;
  }

  Future<void> stop() async {
    _clearQueue();
    try {
      await _tts.stop();
    } catch (_) {}
    _isPlaying = false;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stop();
  }
}
