import 'package:flutter_tts/flutter_tts.dart';

class AndroidOfflineVoiceCapabilityProbe {
  final FlutterTts _tts;

  AndroidOfflineVoiceCapabilityProbe(this._tts);

  Future<List<String>> getVerifiedOfflineLocales() async {
    try {
      final locales = <String>{};
      final seen = <String>{};
      final voices = await _tts.getVoices;
      if (voices is List) {
        for (final dynamic v in voices) {
          if (v is! Map) continue;
          final voice = v;
          final rawLocale = voice['locale']?.toString() ?? '';
          if (rawLocale.isEmpty) continue;

          final String features = (voice['features'] ?? '').toString().toLowerCase();
          final bool offlineEvidence = features.contains('notrequired');
          final bool conflictingEvidence = features.contains('network') || features.contains('notinstalled');

          // An advertised language, or absent network metadata, is not offline proof.
          if (!offlineEvidence || conflictingEvidence) continue;

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
      }
      final dynamic langs = await _tts.getLanguages;
      if (langs is List) {
        for (final lang in langs) {
          if (lang is String && lang.isNotEmpty) {
             final locale = lang.trim().replaceAll('_', '-');
             final key = locale.toLowerCase();
             if (seen.contains(key)) continue;
             try {
                final Object? installed = await _tts.isLanguageInstalled(locale);
                if (installed != true && installed != 1) continue;
                seen.add(key);
                locales.add(locale);
             } catch (_) {
             }
          }
        }
      }
      return locales.toList();
    } catch (_) {
      return [];
    }
  }
}
