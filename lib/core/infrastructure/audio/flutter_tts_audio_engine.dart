import 'package:flutter_tts/flutter_tts.dart';

import '../../../features/audio/domain/services/offline_tts_engine.dart';
import '../../../language/german/german_speech_profile.dart';
import '../../../language/language_speech_profile.dart';
import 'audio_service.dart';

final class FlutterOfflineTtsEngine
    implements OfflineTtsEngine, GermanAudioEngine {
  FlutterOfflineTtsEngine({FlutterTts? engine})
      : _engine = engine ?? FlutterTts();

  final FlutterTts _engine;
  Map<String, String>? _selectedVoice;
  String? _selectedLanguage;
  bool _closed = false;

  @override
  Future<OfflineTtsAvailability> probe(LanguageSpeechProfile profile) async {
    if (_closed) return OfflineTtsAvailability.unavailable;
    if (_selectedVoice != null && _selectedLanguage == profile.languageCode) {
      return OfflineTtsAvailability.ready;
    }
    try {
      final rawVoices = await _engine.getVoices;
      if (rawVoices is! List) return OfflineTtsAvailability.unavailable;
      final voice = selectOfflineVoice(
        rawVoices,
        profile.preferredTtsLocales,
      );
      if (voice == null) return OfflineTtsAvailability.unavailable;

      final locale = voice['locale'];
      if (locale == null || locale.isEmpty) {
        return OfflineTtsAvailability.unavailable;
      }
      final installed = await _engine.isLanguageInstalled(locale);
      if (installed != true) {
        return OfflineTtsAvailability.unavailable;
      }

      _selectedVoice = voice;
      _selectedLanguage = profile.languageCode;
      return OfflineTtsAvailability.ready;
    } on Object {
      return OfflineTtsAvailability.unavailable;
    }
  }

  @override
  Future<bool> speak({
    required String text,
    required LanguageSpeechProfile profile,
    required double rate,
  }) async {
    if (_closed || text.trim().isEmpty) return false;
    if (await probe(profile) != OfflineTtsAvailability.ready) return false;
    final voice = _selectedVoice;
    if (voice == null) return false;
    try {
      await _engine.stop();
      await _engine.setVoice(voice);
      await _engine.setLanguage(voice['locale']!);
      await _engine.setSpeechRate(rate.clamp(.1, 1.0));
      await _engine.setPitch(1.0);
      await _engine.setVolume(1.0);
      await _engine.awaitSpeakCompletion(true);
      final result = await _engine.speak(text.trim());
      return result == 1 || result == true || result == null;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> speakGerman(String text, {required double rate}) async {
    final spoken = await speak(
      text: text,
      profile: const GermanSpeechProfile(),
      rate: rate,
    );
    if (!spoken) throw StateError('offline_german_tts_unavailable');
  }

  @override
  Future<void> pause() async {
    if (_closed) return;
    await _engine.pause();
  }

  @override
  Future<void> stop() async {
    if (_closed) return;
    try {
      await _engine.stop();
    } on Object {
      // Platform failures remain inside the infrastructure adapter boundary.
    }
  }

  @override
  Future<void> shutdown() async {
    if (_closed) return;
    _closed = true;
    try {
      await _engine.stop();
    } on Object {
      // Platform failures remain inside the infrastructure adapter boundary.
    }
  }

  @override
  Future<void> dispose() => shutdown();

  static Map<String, String>? selectOfflineVoice(
    List<dynamic> voices,
    List<String> preferredLocales,
  ) {
    final preferred = preferredLocales
        .map(_normalizeLocale)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    for (final locale in preferred) {
      for (final raw in voices) {
        if (raw is! Map) continue;
        final normalized = <String, String>{
          for (final entry in raw.entries)
            entry.key.toString(): entry.value.toString(),
        };
        final voiceLocale = _normalizeLocale(normalized['locale'] ?? '');
        if (voiceLocale != locale && !voiceLocale.startsWith('$locale-')) {
          continue;
        }
        if (!_isStrictlyOfflineVoice(normalized)) continue;
        final name = normalized['name']?.trim() ?? '';
        if (name.isEmpty) continue;
        return <String, String>{
          'name': name,
          'locale': normalized['locale']!,
        };
      }
    }
    return null;
  }

  static bool _isStrictlyOfflineVoice(Map<String, String> voice) {
    const networkKeys = <String>[
      'network_required',
      'networkRequired',
      'requiresNetwork',
    ];
    for (final key in networkKeys) {
      final value = (voice[key] ?? '').trim().toLowerCase();
      if (value == 'true' || value == '1' || value == 'yes') {
        return false;
      }
    }

    final features = (voice['features'] ?? '').trim().toLowerCase();
    if (features.contains('notinstalled') ||
        features.contains('networktts') ||
        features.contains('network_tts') ||
        features.contains('requiresnetwork')) {
      return false;
    }
    return true;
  }

  static String _normalizeLocale(String value) =>
      value.trim().replaceAll('_', '-').toLowerCase();
}
