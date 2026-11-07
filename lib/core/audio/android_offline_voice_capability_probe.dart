import 'package:flutter_tts/flutter_tts.dart';

class AndroidOfflineVoiceCapabilityProbe {
  final FlutterTts _tts;

  AndroidOfflineVoiceCapabilityProbe(this._tts);

  Future<List<String>> getVerifiedOfflineLocales() async {
    try {
      final locales = <String>{};
      final voices = await _tts.getVoices;
      final seen = <String>{};
      if (voices is List) {
        for (final voice in voices) {
          if (voice is! Map) continue;
          final rawLocale = voice['locale'];
          if (rawLocale is! String || rawLocale.isEmpty) continue;

          final isNetworkOnly = voice['isNetworkConnectionRequired'] == true;
          final isInstalled = voice['isInstalled'] == true;

          // An advertised language, or absent network metadata, is not offline proof.
          final offlineEvidence = isInstalled && !isNetworkOnly;
          if (!offlineEvidence) continue;

          final features = (voice['features'] ?? '').toString().toLowerCase();
          if (features.contains('notinstalled') || features.contains('network')) {
            continue;
          }
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
          if (lang is String && lang.isNotEmpty) locales.add(lang);
        }
      }
      return locales.toList();
    } catch (_) {
      return [];
    }
  }
}
