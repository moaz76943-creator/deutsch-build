import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../core/audio/offline_audio_capability.dart';
import '../core/audio/offline_audio_dispatcher.dart';
import 'language_pack_manager.dart';

/// Device capability state. A registered language is not necessarily voiced.
enum TtsStatus {
  idle,
  initializing,
  ready,
  speaking,
  completed,
  stopped,
  voiceMissing,
  unsupportedLanguage,
  unavailable,
  error,
}

typedef TtsStatusCallback = void Function(
  TtsStatus status, {
  String? locale,
  String? message,
});

/// Offline-first system TTS. No network synthesis or foreign-language fallback.
class TtsService {
  TtsService({
    FlutterTts? flutterTts,
    LanguagePackManager? languagePackManager,
    MethodChannel? installerChannel,
    this.onStatus,
    double speechRate = 0.48,
    double volume = 1.0,
    double pitch = 1.0,
  })  : _tts = flutterTts,
        _languages = languagePackManager ?? LanguagePackManager(),
        _installerChannel = installerChannel ??
            const MethodChannel('com.deutsch_bilarabi.app/tts_settings'),
        _speechRate = _bounded(speechRate, 0.0, 1.0, 0.48),
        _volume = _bounded(volume, 0.0, 1.0, 1.0),
        _pitch = _bounded(pitch, 0.5, 2.0, 1.0);

  FlutterTts? _tts;
  FlutterTts get _engine => _tts ??= FlutterTts();
  final LanguagePackManager _languages;
  final MethodChannel _installerChannel;
  TtsStatusCallback? onStatus;

  double _speechRate;
  double _volume;
  double _pitch;
  TtsStatus _status = TtsStatus.idle;
  String? _activeLocale;
  bool _ready = false;
  bool _disposed = false;
  bool _isSpeaking = false;
  int _requestEpoch = 0;
  Future<bool>? _initialization;
  Future<void> _speechQueue = Future<void>.value();

  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  TtsStatus get status => _status;
  String? get activeLocale => _activeLocale;

  String getTtsLocale(String languageCode) =>
      OfflineAudioCapability.getFallbackLocale(languageCode) ?? '';
  List<String> get supportedLanguages => [
        'af',
        'am',
        'ar',
        'az',
        'be',
        'bg',
        'bn',
        'bs',
        'ca',
        'cs',
        'cy',
        'da',
        'de',
        'el',
        'en',
        'eo',
        'es',
        'et',
        'eu',
        'fa',
        'fi',
        'fil',
        'fr',
        'ga',
        'gl',
        'gu',
        'ha',
        'he',
        'hi',
        'hr',
        'hu',
        'hy',
        'id',
        'ig',
        'is',
        'it',
        'ja',
        'jv',
        'ka',
        'kk',
        'km',
        'kn',
        'ko',
        'ku',
        'ky',
        'la',
        'nl',
        'no',
        'pl',
        'pt',
        'ro',
        'ru',
        'sk',
        'sl',
        'sq',
        'sr',
        'sv',
        'sw',
        'ta',
        'te',
        'th',
        'tr',
        'uk',
        'ur',
        'vi',
        'zh'
      ];
  bool isLanguageSupported(String languageCode) => true;
  TextDirection textDirectionFor(String languageCode) {
    final lower = languageCode.toLowerCase();
    final isRtl = lower.startsWith('ar') ||
        lower.startsWith('he') ||
        lower.startsWith('fa') ||
        lower.startsWith('ur');
    return isRtl ? TextDirection.rtl : TextDirection.ltr;
  }

  static double _bounded(
    double value,
    double min,
    double max,
    double defaultValue,
  ) =>
      value.isFinite ? value.clamp(min, max).toDouble() : defaultValue;

  void _emit(TtsStatus next, {String? locale, String? message}) {
    if (_disposed) return;
    _status = next;
    try {
      onStatus?.call(next, locale: locale, message: message);
    } catch (_) {
      // User-provided UI callbacks must not crash speech playback.
    }
  }

  Future<bool> initialize() {
    if (_disposed) return Future<bool>.value(false);
    if (_ready) return Future<bool>.value(true);
    return _initialization ??= _initialize().then((result) {
      if (!result) _initialization = null; // Permit retry after engine install.
      return result;
    });
  }

  Future<void> _applyParameters() async {
    await _engine.setSpeechRate(_speechRate);
    await _engine.setVolume(_volume);
    await _engine.setPitch(_pitch);
  }

  Future<bool> _initialize() async {
    _emit(TtsStatus.initializing);
    try {
      await _applyParameters();
      if (_disposed) return false;
      _ready = true;
      _emit(TtsStatus.ready);
      return true;
    } catch (error) {
      _ready = false;
      _emit(TtsStatus.unavailable, message: error.toString());
      return false;
    }
  }

  /// Limits: speech rate/volume 0..1, pitch 0.5..2.0. Default rate: 0.48.
  Future<bool> configure({
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    if (_disposed) return false;
    if (speechRate != null) {
      _speechRate = _bounded(speechRate, 0.0, 1.0, _speechRate);
    }
    if (volume != null) _volume = _bounded(volume, 0.0, 1.0, _volume);
    if (pitch != null) _pitch = _bounded(pitch, 0.5, 2.0, _pitch);
    if (!await initialize()) return false;
    try {
      await _applyParameters();
      return true;
    } catch (error) {
      _emit(TtsStatus.error, message: error.toString());
      return false;
    }
  }

  /// Checks the requested locale rather than silently selecting English.
  /// On Android, a locale must be available AND installed for offline use.
  Future<bool> isVoiceAvailable(String languageCode) async {
    final locale = getTtsLocale(languageCode);
    if (locale.isEmpty) {
      _emit(TtsStatus.unsupportedLanguage, message: languageCode);
      return false;
    }
    if (!await initialize()) return false;
    try {
      final available = await _engine.isLanguageAvailable(locale);
      if (available != true && available != 1) {
        _emit(TtsStatus.voiceMissing,
            locale: locale, message: 'TTS locale is unavailable on device');
        return false;
      }
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final installed = await _engine.isLanguageInstalled(locale);
        if (installed != true && installed != 1) {
          _emit(TtsStatus.voiceMissing,
              locale: locale,
              message: 'Install offline voice data for $locale');
          return false;
        }
      }
      _emit(TtsStatus.ready, locale: locale);
      return true;
    } catch (error) {
      _emit(TtsStatus.voiceMissing, locale: locale, message: error.toString());
      return false;
    }
  }

  /// Voice-readiness check used by the installer prompt.
  ///
  /// Reuses the offline-first BCP-47 check and preserves TtsStatus callbacks.
  /// An engine failure is not mistaken for missing voice data.
  Future<bool> isLanguageVoiceInstalled(String languageTag) async {
    if (_disposed) throw StateError('TTS service has been disposed.');
    if (languageTag.trim().isEmpty) {
      throw ArgumentError.value(languageTag, 'languageTag', 'Cannot be empty');
    }
    _ensureAndroidInstallerPlatform();
    final installed = await isVoiceAvailable(languageTag);
    if (!installed && _status != TtsStatus.voiceMissing) {
      throw StateError('Unable to verify TTS voice data for $languageTag.');
    }
    return installed;
  }

  /// Requests Android's native TTS installer and its settings fallback.
  Future<void> openSystemTtsInstallSettings() async {
    if (_disposed) throw StateError('TTS service has been disposed.');
    _ensureAndroidInstallerPlatform();
    try {
      final opened =
          await _installerChannel.invokeMethod<bool>('openTtsInstall');
      if (opened != true) {
        throw StateError('Android did not open the TTS installer.');
      }
    } on MissingPluginException {
      const message = 'Android TTS installation channel is not registered.';
      _emit(TtsStatus.error, message: message);
      throw StateError(message);
    } on PlatformException catch (error) {
      _emit(TtsStatus.error, message: error.message ?? error.code);
      rethrow;
    }
  }

  void _ensureAndroidInstallerPlatform() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('TTS voice installation is Android-only.');
    }
  }

  bool _isCurrent(int epoch) => !_disposed && epoch == _requestEpoch;

  /// Newer requests invalidate queued older utterances.
  Future<bool> speak(String text, {String languageCode = 'de'}) {
    final epoch = ++_requestEpoch;
    final next = _speechQueue.then((_) => _speakIfCurrent(
          epoch,
          text,
          languageCode,
        ));
    _speechQueue =
        next.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return next.catchError((Object error) {
      _emit(TtsStatus.error, message: error.toString());
      return false;
    });
  }

  Future<bool> _speakIfCurrent(
      int epoch, String text, String languageCode) async {
    if (!_isCurrent(epoch)) return false;
    if (text.trim().isEmpty) return false;
    final locale = getTtsLocale(languageCode);
    if (locale.isEmpty) {
      _emit(TtsStatus.unsupportedLanguage, message: languageCode);
      return false;
    }

    if (!await isVoiceAvailable(languageCode) || !_isCurrent(epoch)) {
      return false;
    }
    try {
      if (!_isCurrent(epoch)) return false;
      _activeLocale = locale;
      _isSpeaking = true;
      _emit(TtsStatus.speaking, locale: locale);
      final result = await OfflineAudioDispatcher.speakText(
        text: text,
        bcp47Locale: locale,
        speechRate: _speechRate,
      );
      if (!_isCurrent(epoch)) return false;
      if (result == false) {
        _isSpeaking = false;
        _emit(TtsStatus.voiceMissing,
            locale: locale, message: 'TTS engine rejected $locale');
        return false;
      }
      _isSpeaking = false;
      _emit(TtsStatus.completed, locale: locale);
      return true;
    } catch (error) {
      _isSpeaking = false;
      _emit(TtsStatus.error, locale: locale, message: error.toString());
      return false;
    }
  }

  Future<void> stop() async {
    ++_requestEpoch;
    if (_disposed) return;
    try {
      OfflineAudioDispatcher.stopCurrentAudio();
    } catch (error) {
      _emit(TtsStatus.error, locale: _activeLocale, message: error.toString());
    } finally {
      _isSpeaking = false;
      _emit(TtsStatus.stopped, locale: _activeLocale);
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    ++_requestEpoch;
    onStatus = null;
    _isSpeaking = false;
    try {
      OfflineAudioDispatcher.stopCurrentAudio();
    } catch (_) {
      // Plugin shutdown is best-effort.
    }
  }
}
