import 'package:flutter_tts/flutter_tts.dart';

class AndroidOfflineVoiceCapabilityProbe {
  final FlutterTts _tts;

  AndroidOfflineVoiceCapabilityProbe(this._tts);

  Future<List<String>> getVerifiedOfflineLocales() async {
    try {
      final Object? voices = await _tts.getVoices;
      if (voices is! List) return [];
      final locales = <String>[];
      final seen = <String>{};
      for (final voice in voices.take(256)) {
        if (voice is! Map) continue;
        final rawLocale = voice['locale'];
        if (rawLocale is! String || rawLocale.trim().isEmpty) continue;
        var offlineEvidence = false;
        var conflictingEvidence = false;
        for (final key in [
          'network_required',
          'networkRequired',
          'requiresNetwork'
        ]) {
          final value = voice[key];
          if (value == null) continue;
          final flag = value.toString().trim().toLowerCase();
          if (flag == 'false' || flag == '0' || flag == 'no') {
            offlineEvidence = true;
          } else {
            conflictingEvidence = true;
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
      return locales;
    } catch (_) {
      return [];
    }
  }
}
