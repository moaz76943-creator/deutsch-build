import 'package:flutter_tts/flutter_tts.dart';

class AndroidOfflineVoiceCapabilityProbe {
  final FlutterTts _tts;

  AndroidOfflineVoiceCapabilityProbe(this._tts);

  Future<List<String>> getVerifiedOfflineLocales() async {
    try {
      final dynamic voices = await _tts.getVoices;
      if (voices == null) return [];

      final List<String> locales = [];
      if (voices is Iterable) {
        for (final voice in voices) {
          if (voice is Map) {
            final locale = voice['locale'] as String?;
            if (locale != null) {
              locales.add(locale);
            }
          }
        }
        // An advertised language, or absent network metadata, is not offline proof.
        if (!offlineEvidence || conflictingEvidence) continue;
        final features = (voice['features'] ?? '').toString().toLowerCase();
        if (features.contains('notinstalled') || features.contains('network'))
          continue;
        final locale = rawLocale.trim().replaceAll('_', '-');
        final key = locale.toLowerCase();
        if (seen.contains(key)) continue;
        try {
          final Object? installed = await _tts.isLanguageInstalled(locale);
          if (installed != true && installed != 1) continue;
        } catch (_) {
          continue;
        }
        seen.add(key);
        locales.add(locale);
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
