import 'dart:async';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'android_offline_voice_capability_probe.dart';
import 'audio_locale_mapping.dart';

class _AudioRequest {
  final String text;
  final String resolvedLocale;
  final double speechRate;
  final int generationToken;
  final Completer<void> completer;

  _AudioRequest({
    required this.text,
    required this.resolvedLocale,
    required this.speechRate,
    required this.generationToken,
    required this.completer,
  });
}

class OfflineAudioPool with WidgetsBindingObserver {
  static final OfflineAudioPool _instance = OfflineAudioPool._internal();
  factory OfflineAudioPool() => _instance;

  final FlutterTts _tts = FlutterTts();
  late final AndroidOfflineVoiceCapabilityProbe _probe;
  bool _observerAdded = false;

  OfflineAudioPool._internal() {
    _probe = AndroidOfflineVoiceCapabilityProbe(_tts);
    _initLocales();
  }

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  String _activeLocale = '';
  double _activeSpeechRate = -1.0;

  List<String> _availableOfflineLocales = [];
  bool _localesInitialized = false;

  final Queue<_AudioRequest> _queue = Queue<_AudioRequest>();
  static const int _maxQueueSize = 10;
  bool _isProcessingQueue = false;

  Future<void> _initLocales() async {
    _availableOfflineLocales = await _probe.getVerifiedOfflineLocales();
    _localesInitialized = true;
  }

  void _ensureObserverAdded() {
    if (!_observerAdded) {
       try {
         WidgetsBinding.instance.addObserver(this);
         _observerAdded = true;
       } catch (_) {
         // WidgetsBinding might not be initialized yet.
       }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      stop();
    }
  }

  Future<void> playWord(
    String text, {
    String locale = 'de-DE',
    double speechRate = 0.45,
    int? generationToken,
  }) async {
    _ensureObserverAdded();

    if (!_localesInitialized) {
      await _initLocales();
    }

    final resolvedLocale = AudioLocaleMapping.resolveOfflineCapability(
        locale, _availableOfflineLocales);

    if (resolvedLocale == null) {
      // Missing voice, handle gracefully (drop request, do not fallback to en/de)
      return;
    }

    if (generationToken != null) {
      // Manage queue bounded size
      if (_queue.length >= _maxQueueSize) {
        final dropped = _queue.removeFirst();
        dropped.completer.complete();
      }

      final completer = Completer<void>();
      _queue.add(_AudioRequest(
        text: text,
        resolvedLocale: resolvedLocale,
        speechRate: speechRate,
        generationToken: generationToken,
        completer: completer,
      ));

      _processQueue(); // Fire and forget sequential processing
      await completer.future;
    }
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;
    _isPlaying = true;

    try {
      while (_queue.isNotEmpty) {
        final request = _queue.removeFirst();

        await _tts.stop();

        if (_activeLocale != request.resolvedLocale) {
          await _tts.setLanguage(request.resolvedLocale);
          _activeLocale = request.resolvedLocale;
        }
        if (_activeSpeechRate != request.speechRate) {
          await _tts.setSpeechRate(request.speechRate);
          _activeSpeechRate = request.speechRate;
        }

        Completer<void> speakCompleter = Completer<void>();
        _tts.setCompletionHandler(() {
          if (!speakCompleter.isCompleted) speakCompleter.complete();
        });
        _tts.setErrorHandler((_) {
           if (!speakCompleter.isCompleted) speakCompleter.complete();
        });

        await _tts.speak(request.text);

        // Wait for it to finish
        await speakCompleter.future;
        request.completer.complete();
      }
    } catch (_) {
    } finally {
      _isProcessingQueue = false;
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    for (final req in _queue) {
       req.completer.complete();
    }
    _queue.clear();
    try {
      await _tts.stop();
    } catch (_) {}
    _isPlaying = false;
  }

  void dispose() {
    if (_observerAdded) {
       try {
         WidgetsBinding.instance.removeObserver(this);
       } catch (_) {}
    }
  }
}
