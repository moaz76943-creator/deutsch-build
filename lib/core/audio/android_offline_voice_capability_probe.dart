import 'package:flutter_tts/flutter_tts.dart';

class AndroidOfflineVoiceCapabilityProbe {
  final FlutterTts _tts;

  AndroidOfflineVoiceCapabilityProbe(this._tts);

  Future<List<String>> getVerifiedOfflineLocales() async {
    try {
      final voices = await _tts.getVoices;
      if (voices == null) return [];

      final List<String> locales = [];
      for (final voice in (voices as Iterable<dynamic>)) {
        if (voice is Map) {
          final locale = voice['locale'] as String?;
          if (locale != null) {
            locales.add(locale);
          }
        }
      }
      // Also get Languages as fallback/addition
      final dynamic langs = await _tts.getLanguages;
      if (langs is List) {
        locales.addAll(langs.cast<String>());
      }
      return locales.toSet().toList();
    } catch (_) {
      return [];
    }
  }
}
