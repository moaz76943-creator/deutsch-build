import 'package:flutter_tts/flutter_tts.dart';

import '../../services/tts_service.dart';

/// Compatibility facade over the process-wide TtsService authority.
///
/// The platform TTS channel remains lazy and no German/default voice is selected
/// before the caller supplies an explicit BCP-47 identity.
class OfflineAudioManager {
  static final OfflineAudioManager instance = OfflineAudioManager._init();

  OfflineAudioManager._init() : _createService = TtsService.new;

  /// Retains the existing test factory without creating another audio manager.
  OfflineAudioManager.forTesting({
    required FlutterTts Function() createTts,
  }) : _createService = (() => TtsService(flutterTts: createTts()));

  final TtsService Function() _createService;
  TtsService? _service;

  bool get isAudioInitialized => _service != null;

  Future<void> speak(
    String text, {
    String locale = 'de-DE',
    double rate = 0.4,
  }) async {
    if (text.trim().isEmpty) return;
    final service = _service ??= _createService();
    final configured = await service.configure(speechRate: rate);
    if (!configured) return;
    await service.speak(text, languageCode: locale);
  }

  Future<void> stop() async {
    final service = _service;
    if (service == null) return;
    await service.stop();
  }
}
