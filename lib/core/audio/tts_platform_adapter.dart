import 'package:flutter_tts/flutter_tts.dart';

/// Minimal platform boundary for local text-to-speech.
///
/// Tests use fakes so no Android channel, network service, microphone, or
/// learner data is required.
abstract class TtsPlatformAdapter {
  void setStartHandler(void Function() handler);
  void setCompletionHandler(void Function() handler);
  void setCancelHandler(void Function() handler);
  void setErrorHandler(void Function(Object? message) handler);

  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion);
  Future<dynamic> setSpeechRate(double rate);
  Future<dynamic> setVolume(double volume);
  Future<dynamic> setPitch(double pitch);
  Future<dynamic> isLanguageAvailable(String locale);
  Future<dynamic> isLanguageInstalled(String locale);
  Future<dynamic> getVoices();
  Future<dynamic> setLanguage(String locale);
  Future<dynamic> setVoice(Map<String, String> voice);
  Future<dynamic> speak(String text);
  Future<dynamic> stop();
}

/// Production adapter around flutter_tts. It is created lazily by TtsService.
class FlutterTtsPlatformAdapter implements TtsPlatformAdapter {
  FlutterTtsPlatformAdapter(this._tts);

  final FlutterTts _tts;

  @override
  void setStartHandler(void Function() handler) => _tts.setStartHandler(handler);

  @override
  void setCompletionHandler(void Function() handler) =>
      _tts.setCompletionHandler(handler);

  @override
  void setCancelHandler(void Function() handler) =>
      _tts.setCancelHandler(handler);

  @override
  void setErrorHandler(void Function(Object? message) handler) =>
      _tts.setErrorHandler((message) => handler(message));

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) =>
      _tts.awaitSpeakCompletion(awaitCompletion);

  @override
  Future<dynamic> setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  @override
  Future<dynamic> setVolume(double volume) => _tts.setVolume(volume);

  @override
  Future<dynamic> setPitch(double pitch) => _tts.setPitch(pitch);

  @override
  Future<dynamic> isLanguageAvailable(String locale) =>
      _tts.isLanguageAvailable(locale);

  @override
  Future<dynamic> isLanguageInstalled(String locale) =>
      _tts.isLanguageInstalled(locale);

  @override
  Future<dynamic> getVoices() async => _tts.getVoices;

  @override
  Future<dynamic> setLanguage(String locale) => _tts.setLanguage(locale);

  @override
  Future<dynamic> setVoice(Map<String, String> voice) => _tts.setVoice(voice);

  @override
  Future<dynamic> speak(String text) => _tts.speak(text);

  @override
  Future<dynamic> stop() => _tts.stop();
}

/// A local voice record returned by the platform engine.
///
/// [networkRequired] is nullable because older engines/plugin versions may not
/// expose that Android metadata. A true value is always treated as online-only.
class TtsVoiceDescriptor {
  const TtsVoiceDescriptor({
    required this.name,
    required this.locale,
    required this.networkRequired,
  });

  final String name;
  final String locale;
  final bool? networkRequired;

  static TtsVoiceDescriptor? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['name']?.toString().trim() ?? '';
    final locale = raw['locale']?.toString().trim() ?? '';
    if (name.isEmpty || locale.isEmpty) return null;
    return TtsVoiceDescriptor(
      name: name,
      locale: locale,
      networkRequired: _asNullableBool(raw['network_required']),
    );
  }

  static bool? _asNullableBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value == 0 ? false : value == 1 ? true : null;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }
}
