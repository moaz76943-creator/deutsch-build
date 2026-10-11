import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Android-only TTS voice availability and installer entry point.
///
/// The installer call requires a native MethodChannel handler registered by
/// Android's host activity. Without that handler, it fails explicitly rather
/// than claiming that the system installer was opened.
class TtsService {
  TtsService({FlutterTts? engine, MethodChannel? installerChannel})
      : _engine = engine ?? FlutterTts(),
        _installerChannel = installerChannel ??
            const MethodChannel('deutsch_bilarabi/tts_installer');

  static const String installTtsDataAction =
      'android.speech.tts.engine.INSTALL_TTS_DATA';
  static const String fallbackPlayStorePackage = 'com.google.android.tts';

  final FlutterTts _engine;
  final MethodChannel _installerChannel;

  /// Returns false when Android reports that the requested voice is missing.
  Future<bool> isLanguageVoiceInstalled(String languageTag) {
    if (languageTag.trim().isEmpty) {
      throw ArgumentError.value(languageTag, 'languageTag', 'Cannot be empty');
    }
    _ensureAndroid();
    return _engine.isLanguageInstalled(languageTag);
  }

  /// Requests Android's voice-data installer, with a Play Store fallback.
  ///
  /// Native host contract: handle `openSystemTtsInstallSettings`, launch
  /// [installTtsDataAction], and if unavailable open the Play Store listing
  /// for [fallbackPlayStorePackage]. The Dart side cannot launch an Android
  /// Intent without that native handler or an installed intent plugin.
  Future<void> openSystemTtsInstallSettings() async {
    _ensureAndroid();
    try {
      await _installerChannel.invokeMethod<void>(
        'openSystemTtsInstallSettings',
        <String, String>{
          'action': installTtsDataAction,
          'fallbackPackage': fallbackPlayStorePackage,
        },
      );
    } on MissingPluginException {
      throw StateError(
        'Android TTS installer handler is not registered. '
        'Install the native deutsch_bilarabi/tts_installer channel handler.',
      );
    }
  }

  void _ensureAndroid() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('TTS voice installation is Android-only.');
    }
  }
}
