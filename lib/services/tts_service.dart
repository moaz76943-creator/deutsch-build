import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show AppLifecycleState, TextDirection, WidgetsBinding, WidgetsBindingObserver;
import 'package:flutter_tts/flutter_tts.dart';

import '../core/audio/audio_session_coordinator.dart';
import '../core/audio/tts_platform_adapter.dart';
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

/// Offline capability result for one requested BCP-47 identity.
enum TtsVoiceCapabilityState {
  installedOffline,
  unsupportedLanguage,
  voiceMissing,
  onlineOnly,
  platformUnverified,
  engineUnavailable,
}

class TtsVoiceCapability {
  const TtsVoiceCapability({
    required this.state,
    required this.requestedLanguage,
    required this.locale,
    required this.voice,
    required this.message,
  });

  final TtsVoiceCapabilityState state;
  final String requestedLanguage;
  final String locale;
  final TtsVoiceDescriptor? voice;
  final String? message;

  bool get canSpeakOffline =>
      state == TtsVoiceCapabilityState.installedOffline;
}

typedef TtsStatusCallback = void Function(
  TtsStatus status, {
  String? locale,
  String? message,
});

class _TtsLifecycleObserver with WidgetsBindingObserver {
  _TtsLifecycleObserver(this.onState);

  final void Function(AppLifecycleState state) onState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onState(state);
}

/// One process-wide platform authority prevents competing system TTS sessions.
///
/// A TtsService remains a lightweight owner facade. Tests can inject an
/// isolated fake adapter without touching the process-wide production engine.
class _TtsEngineAuthority {
  _TtsEngineAuthority(this._createAdapter);

  final TtsPlatformAdapter Function() _createAdapter;
  TtsPlatformAdapter? _adapter;
  Future<bool>? _initialization;
  bool _ready = false;

  Future<void> _tail = Future<void>.value();
  int _generation = 0;
  int? _activeOwner;
  int? _activeGeneration;
  String? _activeLocale;
  TtsStatusCallback? _activeStatus;
  bool _isSpeaking = false;
  String? _activeSessionId;
  final AudioSessionCoordinator _session = AudioSessionCoordinator.shared;

  bool get isInitialized => _ready;
  TtsPlatformAdapter get _engine => _adapter ??= _createAdapter();

  Future<bool> initialize(Duration timeout) {
    if (_ready) return Future<bool>.value(true);
    return _initialization ??= _initialize(timeout).then((ready) {
      if (!ready) _initialization = null;
      return ready;
    });
  }

  Future<bool> _initialize(Duration timeout) async {
    try {
      final engine = _engine;
      engine.setStartHandler(() {
        if (!_isActiveGeneration) return;
        _activeStatus?.call(TtsStatus.speaking, locale: _activeLocale);
      });
      engine.setCompletionHandler(() {
        if (!_isActiveGeneration) return;
        _isSpeaking = false;
        _activeStatus?.call(TtsStatus.completed, locale: _activeLocale);
        _clearActive();
      });
      engine.setCancelHandler(() {
        if (!_isActiveGeneration) return;
        _isSpeaking = false;
        _activeStatus?.call(TtsStatus.stopped, locale: _activeLocale);
        _clearActive();
      });
      engine.setErrorHandler((message) {
        if (!_isActiveGeneration) return;
        _isSpeaking = false;
        _activeStatus?.call(
          TtsStatus.error,
          locale: _activeLocale,
          message: message?.toString(),
        );
        _clearActive();
      });
      await engine.awaitSpeakCompletion(false).timeout(timeout);
      _ready = true;
      return true;
    } catch (_) {
      _ready = false;
      return false;
    }
  }

  bool get _isActiveGeneration =>
      _isSpeaking &&
      _activeGeneration != null &&
      _activeGeneration == _generation;

  void _clearActive() {
    final sessionId = _activeSessionId;
    if (sessionId != null) _session.releaseFocus(sessionId);
    _activeSessionId = null;
    _activeOwner = null;
    _activeGeneration = null;
    _activeLocale = null;
    _activeStatus = null;
  }

  Future<void> applyParameters({
    required int owner,
    required double speechRate,
    required double volume,
    required double pitch,
    required Duration timeout,
  }) async {
    if (_isSpeaking && _activeOwner != owner) return;
    await _engine.setSpeechRate(speechRate).timeout(timeout);
    await _engine.setVolume(volume).timeout(timeout);
    await _engine.setPitch(pitch).timeout(timeout);
  }

  Future<dynamic> languageAvailable(String locale, Duration timeout) =>
      _engine.isLanguageAvailable(locale).timeout(timeout);

  Future<dynamic> languageInstalled(String locale, Duration timeout) =>
      _engine.isLanguageInstalled(locale).timeout(timeout);

  Future<dynamic> voices(Duration timeout) => _engine.getVoices().timeout(timeout);

  Future<bool> speak({
    required int owner,
    required bool Function() ownerIsCurrent,
    required String text,
    required String locale,
    required TtsVoiceDescriptor? voice,
    required double speechRate,
    required double volume,
    required double pitch,
    required Duration timeout,
    required TtsStatusCallback emit,
  }) {
    final generation = ++_generation;
    final next = _tail.then(
      (_) => _speakIfCurrent(
        generation: generation,
        owner: owner,
        ownerIsCurrent: ownerIsCurrent,
        text: text,
        locale: locale,
        voice: voice,
        speechRate: speechRate,
        volume: volume,
        pitch: pitch,
        timeout: timeout,
        emit: emit,
      ),
    );
    _tail = next.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return next;
  }

  Future<bool> _speakIfCurrent({
    required int generation,
    required int owner,
    required bool Function() ownerIsCurrent,
    required String text,
    required String locale,
    required TtsVoiceDescriptor? voice,
    required double speechRate,
    required double volume,
    required double pitch,
    required Duration timeout,
    required TtsStatusCallback emit,
  }) async {
    if (generation != _generation || !ownerIsCurrent()) return false;
    try {
      await _engine.stop().timeout(timeout);
      if (_activeGeneration != generation) {
        _isSpeaking = false;
        _clearActive();
      }
      if (generation != _generation || !ownerIsCurrent()) return false;

      final languageResult = await _engine.setLanguage(locale).timeout(timeout);
      if (_rejected(languageResult)) return false;

      if (voice != null) {
        final voiceResult = await _engine.setVoice(<String, String>{
          'name': voice.name,
          'locale': voice.locale,
        }).timeout(timeout);
        if (_rejected(voiceResult)) return false;
      }

      await _engine.setSpeechRate(speechRate).timeout(timeout);
      await _engine.setVolume(volume).timeout(timeout);
      await _engine.setPitch(pitch).timeout(timeout);
      if (generation != _generation || !ownerIsCurrent()) return false;

      final sessionId = 'tts:$owner:$generation';
      if (!_session.requestFocus(sessionId)) return false;
      _activeSessionId = sessionId;
      _activeOwner = owner;
      _activeGeneration = generation;
      _activeLocale = locale;
      _activeStatus = emit;
      _isSpeaking = true;

      final result = await _engine.speak(text).timeout(timeout);
      if (generation != _generation || !ownerIsCurrent()) {
        if (_activeOwner == owner) {
          await _safeStop(timeout);
          _clearActive();
          _isSpeaking = false;
        }
        return false;
      }
      if (_rejected(result)) {
        _isSpeaking = false;
        _clearActive();
        return false;
      }
      emit(TtsStatus.speaking, locale: locale);
      return true;
    } catch (_) {
      if (_activeOwner == owner) {
        _isSpeaking = false;
        _clearActive();
      }
      return false;
    }
  }

  Future<void> stopOwner(int owner, Duration timeout) async {
    if (_activeOwner != owner) return;
    _isSpeaking = false;
    await _safeStop(timeout);
    _clearActive();
  }

  Future<void> _safeStop(Duration timeout) async {
    try {
      await _engine.stop().timeout(timeout);
    } catch (_) {
      // A broken engine must not block navigation or shutdown.
    }
  }

  static bool _rejected(Object? result) =>
      result == false || (result is num && result <= 0);
}

/// Offline-first system TTS. No network synthesis or foreign-language fallback.
class TtsService {
  TtsService({
    FlutterTts? flutterTts,
    TtsPlatformAdapter? adapter,
    LanguagePackManager? languagePackManager,
    MethodChannel? installerChannel,
    this.onStatus,
    double speechRate = 0.48,
    double volume = 1.0,
    double pitch = 1.0,
    this.initializationTimeout = const Duration(seconds: 4),
    this.operationTimeout = const Duration(seconds: 4),
  })  : assert(flutterTts == null || adapter == null),
        _languages = languagePackManager ?? LanguagePackManager(),
        _installerChannel = installerChannel ??
            const MethodChannel('com.deutsch_bilarabi.app/tts_settings'),
        _speechRate = _bounded(speechRate, 0.0, 1.0, 0.48),
        _volume = _bounded(volume, 0.0, 1.0, 1.0),
        _pitch = _bounded(pitch, 0.5, 2.0, 1.0),
        _authority = adapter != null
            ? _TtsEngineAuthority(() => adapter)
            : flutterTts != null
                ? _TtsEngineAuthority(
                    () => FlutterTtsPlatformAdapter(flutterTts),
                  )
                : _sharedAuthority,
        _ownerId = _nextOwnerId++;

  static const int maximumSpeechCharacters = 4000;
  static int _nextOwnerId = 1;
  static final _TtsEngineAuthority _sharedAuthority =
      _TtsEngineAuthority(() => FlutterTtsPlatformAdapter(FlutterTts()));

  final LanguagePackManager _languages;
  final MethodChannel _installerChannel;
  final _TtsEngineAuthority _authority;
  final int _ownerId;
  final Duration initializationTimeout;
  final Duration operationTimeout;
  TtsStatusCallback? onStatus;

  double _speechRate;
  double _volume;
  double _pitch;
  TtsStatus _status = TtsStatus.idle;
  String? _activeLocale;
  bool _disposed = false;
  int _requestEpoch = 0;
  Future<bool>? _initialization;
  _TtsLifecycleObserver? _lifecycleObserver;

  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  TtsStatus get status => _status;
  String? get activeLocale => _activeLocale;
  bool get isInitialized => _authority.isInitialized;

  String getTtsLocale(String languageCode) =>
      _languages.getTtsLocale(languageCode);
  List<String> get supportedLanguages => _languages.supportedLanguages;
  bool isLanguageSupported(String languageCode) =>
      _languages.isLanguageSupported(languageCode);
  TextDirection textDirectionFor(String languageCode) =>
      _languages.textDirectionFor(languageCode);

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
    if (locale != null) _activeLocale = locale;
    try {
      onStatus?.call(next, locale: locale, message: message);
    } catch (_) {
      // UI callbacks are untrusted presentation code, not engine authority.
    }
  }

  Future<bool> initialize() {
    if (_disposed) return Future<bool>.value(false);
    _attachLifecycleObserver();
    if (_authority.isInitialized) return Future<bool>.value(true);
    return _initialization ??= _initialize().then((result) {
      if (!result) _initialization = null;
      return result;
    });
  }

  void _attachLifecycleObserver() {
    if (_lifecycleObserver != null) return;
    try {
      final observer = _TtsLifecycleObserver(
        (state) => unawaited(handleLifecycleState(state)),
      );
      WidgetsBinding.instance.addObserver(observer);
      _lifecycleObserver = observer;
    } catch (_) {
      // Headless callers may not own a WidgetsBinding; speech still works.
    }
  }

  void _detachLifecycleObserver() {
    final observer = _lifecycleObserver;
    if (observer == null) return;
    try {
      WidgetsBinding.instance.removeObserver(observer);
    } catch (_) {}
    _lifecycleObserver = null;
  }

  Future<bool> _initialize() async {
    _emit(TtsStatus.initializing);
    final ready = await _authority.initialize(initializationTimeout);
    if (_disposed) return false;
    if (!ready) {
      _emit(
        TtsStatus.unavailable,
        message: 'Local TTS engine initialization timed out or failed.',
      );
      return false;
    }
    _emit(TtsStatus.ready);
    return true;
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
    if (volume != null) {
      _volume = _bounded(volume, 0.0, 1.0, _volume);
    }
    if (pitch != null) {
      _pitch = _bounded(pitch, 0.5, 2.0, _pitch);
    }
    if (!await initialize()) return false;
    try {
      await _authority.applyParameters(
        owner: _ownerId,
        speechRate: _speechRate,
        volume: _volume,
        pitch: _pitch,
        timeout: operationTimeout,
      );
      return true;
    } catch (error) {
      _emit(TtsStatus.error, message: error.toString());
      return false;
    }
  }

  /// Probes one requested identity only. It never downloads a voice.
  ///
  /// Android is fail-closed: both language availability and installed language
  /// data are required. If the engine explicitly reports that every matching
  /// voice requires network access, speech is rejected.
  Future<TtsVoiceCapability> probeVoiceCapability(String languageCode) async {
    final locale = getTtsLocale(languageCode);
    if (locale.isEmpty) {
      _emit(TtsStatus.unsupportedLanguage, message: languageCode);
      return TtsVoiceCapability(
        state: TtsVoiceCapabilityState.unsupportedLanguage,
        requestedLanguage: languageCode,
        locale: '',
        voice: null,
        message: 'Unsupported BCP-47 language identity.',
      );
    }
    if (!await initialize()) {
      return TtsVoiceCapability(
        state: TtsVoiceCapabilityState.engineUnavailable,
        requestedLanguage: languageCode,
        locale: locale,
        voice: null,
        message: 'Local TTS engine is unavailable.',
      );
    }

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _emit(
        TtsStatus.unavailable,
        locale: locale,
        message: 'Offline voice installation cannot be verified on this platform.',
      );
      return TtsVoiceCapability(
        state: TtsVoiceCapabilityState.platformUnverified,
        requestedLanguage: languageCode,
        locale: locale,
        voice: null,
        message: 'Offline installation is not verifiable on this platform.',
      );
    }

    try {
      final available = await _authority.languageAvailable(
        locale,
        operationTimeout,
      );
      if (!_positive(available)) {
        return _missingCapability(
          languageCode,
          locale,
          'Requested TTS locale is unavailable on this device.',
        );
      }

      final installed = await _authority.languageInstalled(
        locale,
        operationTimeout,
      );
      if (!_positive(installed)) {
        return _missingCapability(
          languageCode,
          locale,
          'Install offline voice data for $locale.',
        );
      }

      List<TtsVoiceDescriptor> voices = const <TtsVoiceDescriptor>[];
      try {
        final rawVoices = await _authority.voices(operationTimeout);
        if (rawVoices is Iterable) {
          voices = rawVoices
              .map<Object?>((item) => item)
              .map(TtsVoiceDescriptor.tryParse)
              .whereType<TtsVoiceDescriptor>()
              .take(256)
              .toList(growable: false);
        }
      } catch (_) {
        // isLanguageInstalled remains the Android offline source of truth.
      }

      final targetLanguage = _primaryLanguage(locale);
      final sameLanguage = voices
          .where((voice) => _primaryLanguage(voice.locale) == targetLanguage)
          .toList(growable: false);

      if (voices.isNotEmpty && sameLanguage.isEmpty) {
        return _missingCapability(
          languageCode,
          locale,
          'No installed voice preserves the requested spoken language.',
        );
      }

      if (sameLanguage.isNotEmpty &&
          sameLanguage.every((voice) => voice.networkRequired == true)) {
        _emit(
          TtsStatus.voiceMissing,
          locale: locale,
          message: 'Only network-required voices were reported for $locale.',
        );
        return TtsVoiceCapability(
          state: TtsVoiceCapabilityState.onlineOnly,
          requestedLanguage: languageCode,
          locale: locale,
          voice: null,
          message: 'Only network-required voices are available.',
        );
      }

      final exactVoices = sameLanguage
          .where(
            (voice) => _normalizeTag(voice.locale) == _normalizeTag(locale),
          )
          .toList(growable: false);
      if (exactVoices.isNotEmpty &&
          exactVoices.every((voice) => voice.networkRequired == true)) {
        _emit(
          TtsStatus.voiceMissing,
          locale: locale,
          message: 'The exact requested locale has only network voices.',
        );
        return TtsVoiceCapability(
          state: TtsVoiceCapabilityState.onlineOnly,
          requestedLanguage: languageCode,
          locale: locale,
          voice: null,
          message: 'The exact requested locale is online-only.',
        );
      }
      final selected = _firstLocalVoice(exactVoices);

      _emit(TtsStatus.ready, locale: locale);
      return TtsVoiceCapability(
        state: TtsVoiceCapabilityState.installedOffline,
        requestedLanguage: languageCode,
        locale: locale,
        voice: selected,
        message: null,
      );
    } on TimeoutException {
      _emit(
        TtsStatus.unavailable,
        locale: locale,
        message: 'Local TTS capability probe timed out.',
      );
      return TtsVoiceCapability(
        state: TtsVoiceCapabilityState.engineUnavailable,
        requestedLanguage: languageCode,
        locale: locale,
        voice: null,
        message: 'Capability probe timed out.',
      );
    } catch (error) {
      _emit(TtsStatus.unavailable, locale: locale, message: error.toString());
      return TtsVoiceCapability(
        state: TtsVoiceCapabilityState.engineUnavailable,
        requestedLanguage: languageCode,
        locale: locale,
        voice: null,
        message: error.toString(),
      );
    }
  }

  TtsVoiceCapability _missingCapability(
    String languageCode,
    String locale,
    String message,
  ) {
    _emit(TtsStatus.voiceMissing, locale: locale, message: message);
    return TtsVoiceCapability(
      state: TtsVoiceCapabilityState.voiceMissing,
      requestedLanguage: languageCode,
      locale: locale,
      voice: null,
      message: message,
    );
  }

  static TtsVoiceDescriptor? _firstLocalVoice(
    Iterable<TtsVoiceDescriptor> voices,
  ) {
    TtsVoiceDescriptor? unknownNetworkRequirement;
    for (final voice in voices) {
      if (voice.networkRequired == false) return voice;
      if (voice.networkRequired == null) {
        unknownNetworkRequirement ??= voice;
      }
    }
    return unknownNetworkRequirement;
  }

  static bool _positive(Object? value) =>
      value == true || (value is num && value > 0);

  static String _primaryLanguage(String tag) {
    final normalized = _normalizeTag(tag);
    if (normalized.isEmpty) return '';
    return normalized.split('-').first.toLowerCase();
  }

  static String _normalizeTag(String tag) {
    final parts = tag.trim().replaceAll('_', '-').split('-');
    if (parts.isEmpty || parts.first.isEmpty) return '';
    final normalized = <String>[parts.first.toLowerCase()];
    for (final part in parts.skip(1)) {
      if (RegExp(r'^[A-Za-z]{4}$').hasMatch(part)) {
        normalized.add(
          part.substring(0, 1).toUpperCase() +
              part.substring(1).toLowerCase(),
        );
      } else if (RegExp(r'^[A-Za-z]{2}$').hasMatch(part)) {
        normalized.add(part.toUpperCase());
      } else {
        normalized.add(part.toLowerCase());
      }
    }
    return normalized.join('-');
  }

  /// Checks an installed offline voice without selecting another language.
  Future<bool> isVoiceAvailable(String languageCode) async {
    final capability = await probeVoiceCapability(languageCode);
    return capability.canSpeakOffline;
  }

  /// Voice-readiness check used by the Android installer prompt.
  Future<bool> isLanguageVoiceInstalled(String languageTag) async {
    if (_disposed) throw StateError('TTS service has been disposed.');
    if (languageTag.trim().isEmpty) {
      throw ArgumentError.value(languageTag, 'languageTag', 'Cannot be empty');
    }
    _ensureAndroidInstallerPlatform();
    final capability = await probeVoiceCapability(languageTag);
    if (capability.state == TtsVoiceCapabilityState.engineUnavailable) {
      throw StateError('Unable to verify TTS voice data for $languageTag.');
    }
    return capability.canSpeakOffline;
  }

  /// Opens Android's native installer only after explicit user action.
  Future<void> openSystemTtsInstallSettings() async {
    if (_disposed) throw StateError('TTS service has been disposed.');
    _ensureAndroidInstallerPlatform();
    try {
      final opened = await _installerChannel
          .invokeMethod<bool>('openTtsInstall')
          .timeout(operationTimeout);
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

  /// Newer requests from any TtsService supersede older queued utterances.
  Future<bool> speak(String text, {String languageCode = 'de'}) async {
    final epoch = ++_requestEpoch;
    final normalizedText = text.trim();
    if (!_isCurrent(epoch) || normalizedText.isEmpty) return false;
    if (normalizedText.length > maximumSpeechCharacters) {
      _emit(
        TtsStatus.error,
        message: 'Speech text exceeds the local playback safety limit.',
      );
      return false;
    }

    final capability = await probeVoiceCapability(languageCode);
    if (!_isCurrent(epoch) || !capability.canSpeakOffline) return false;

    final success = await _authority.speak(
      owner: _ownerId,
      ownerIsCurrent: () => _isCurrent(epoch),
      text: normalizedText,
      locale: capability.locale,
      voice: capability.voice,
      speechRate: _speechRate,
      volume: _volume,
      pitch: _pitch,
      timeout: operationTimeout,
      emit: _emit,
    );
    if (!_isCurrent(epoch)) return false;
    if (!success) {
      _emit(
        TtsStatus.error,
        locale: capability.locale,
        message: 'Local TTS engine failed to start playback.',
      );
    }
    return success;
  }

  Future<void> stop() async {
    ++_requestEpoch;
    if (_disposed) return;
    await _authority.stopOwner(_ownerId, operationTimeout);
    _emit(TtsStatus.stopped, locale: _activeLocale);
  }

  /// Pauses speech activity when the owning screen/app leaves the foreground.
  Future<void> handleLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await stop();
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    ++_requestEpoch;
    _detachLifecycleObserver();
    await _authority.stopOwner(_ownerId, operationTimeout);
    _disposed = true;
    onStatus = null;
  }
}
