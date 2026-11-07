import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutsch_bilarabi/core/audio/tts_platform_adapter.dart';

class AndroidOfflineVoiceCapabilityProbe {
  final FlutterTts _tts;

  AndroidOfflineVoiceCapabilityProbe(this._tts);

  Future<List<String>> getVerifiedOfflineLocales() async {
    try {
      final locales = <String>[];
      final Set<String> seen = {};
      final dynamic voices = await _tts.getVoices;

      if (voices is List) {
        for (final voiceMap in voices) {
          final voice = TtsVoiceDescriptor.tryParse(voiceMap);
          if (voice == null) continue;

          final rawLocale = voice.locale;
          if (rawLocale.isEmpty) continue;

          final bool offlineEvidence = voice.networkRequired == false;
          final bool conflictingEvidence = voice.networkRequired == true;

          // An advertised language, or absent network metadata, is not offline proof.
          if (!offlineEvidence || conflictingEvidence) continue;

          final features = (voiceMap['features'] ?? '').toString().toLowerCase();
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

      // Fallback: If getVoices isn't fully supported, just return what getLanguages says.
      if (locales.isEmpty) {
        final dynamic langs = await _tts.getLanguages;
        if (langs is List) {
          for (final lang in langs) {
            if (lang is String && lang.isNotEmpty) {
              final locale = lang.trim().replaceAll('_', '-');
              final key = locale.toLowerCase();
              if (!seen.contains(key)) {
                seen.add(key);
                locales.add(locale);
              }
            }
          }
        }
      }

      return locales;
    } catch (_) {
      return [];
    }
  }
}
