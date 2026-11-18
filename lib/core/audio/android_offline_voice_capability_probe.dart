import 'package:flutter_tts/flutter_tts.dart';

class AndroidOfflineVoiceCapabilityProbe {
  final FlutterTts _tts;

  AndroidOfflineVoiceCapabilityProbe(this._tts);

  Future<List<String>> getVerifiedOfflineLocales() async {
    try {
      final locales = <String>{};
      final voices = await _tts.getVoices;
      if (voices is List) {
        for (final voice in voices) {
          if (voice is! Map) continue;
          final locale = voice['locale'];
          if (locale is String && locale.isNotEmpty) {
            locales.add(locale);
          }
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