import 'package:flutter/material.dart';

/// Script families used to select platform font fallbacks without bundling
/// additional font assets into the application.
enum ScriptFamily {
  latin,
  cyrillic,
  greek,
  arabic,
  devanagari,
  bengali,
  gurmukhi,
  gujarati,
  tamil,
  telugu,
  kannada,
  malayalam,
  odia,
  sinhala,
  thai,
  lao,
  khmer,
  myanmar,
  cjk,
  ethiopic,
  armenian,
  georgian,
  thaana,
}

/// Resolves script-aware [TextStyle] fallbacks for the application's language
/// catalog.
///
/// The listed families are platform font family names only. No font binaries
/// are bundled by this class, so the resolver does not increase APK size.
class MultiScriptTypography {
  MultiScriptTypography._();

  static const Map<String, ScriptFamily> _scriptTags = <String, ScriptFamily>{
    'latn': ScriptFamily.latin,
    'cyrl': ScriptFamily.cyrillic,
    'grek': ScriptFamily.greek,
    'arab': ScriptFamily.arabic,
    'deva': ScriptFamily.devanagari,
    'beng': ScriptFamily.bengali,
    'guru': ScriptFamily.gurmukhi,
    'gujr': ScriptFamily.gujarati,
    'taml': ScriptFamily.tamil,
    'telu': ScriptFamily.telugu,
    'knda': ScriptFamily.kannada,
    'mlym': ScriptFamily.malayalam,
    'orya': ScriptFamily.odia,
    'sinh': ScriptFamily.sinhala,
    'thai': ScriptFamily.thai,
    'laoo': ScriptFamily.lao,
    'khmr': ScriptFamily.khmer,
    'mymr': ScriptFamily.myanmar,
    'hani': ScriptFamily.cjk,
    'hans': ScriptFamily.cjk,
    'hant': ScriptFamily.cjk,
    'jpan': ScriptFamily.cjk,
    'kore': ScriptFamily.cjk,
    'ethi': ScriptFamily.ethiopic,
    'armn': ScriptFamily.armenian,
    'geor': ScriptFamily.georgian,
    'thaa': ScriptFamily.thaana,
  };

  static const Map<String, ScriptFamily> _languageScripts =
      <String, ScriptFamily>{
    'ru': ScriptFamily.cyrillic,
    'uk': ScriptFamily.cyrillic,
    'bg': ScriptFamily.cyrillic,
    'be': ScriptFamily.cyrillic,
    'mk': ScriptFamily.cyrillic,
    'sr': ScriptFamily.cyrillic,
    'kk': ScriptFamily.cyrillic,
    'ky': ScriptFamily.cyrillic,
    'tg': ScriptFamily.cyrillic,
    'tt': ScriptFamily.cyrillic,
    'ba': ScriptFamily.cyrillic,
    'mn': ScriptFamily.cyrillic,
    'el': ScriptFamily.greek,
    'ar': ScriptFamily.arabic,
    'fa': ScriptFamily.arabic,
    'ur': ScriptFamily.arabic,
    'ps': ScriptFamily.arabic,
    'sd': ScriptFamily.arabic,
    'ug': ScriptFamily.arabic,
    'hi': ScriptFamily.devanagari,
    'mr': ScriptFamily.devanagari,
    'ne': ScriptFamily.devanagari,
    'bn': ScriptFamily.bengali,
    'as': ScriptFamily.bengali,
    'pa': ScriptFamily.gurmukhi,
    'gu': ScriptFamily.gujarati,
    'ta': ScriptFamily.tamil,
    'te': ScriptFamily.telugu,
    'kn': ScriptFamily.kannada,
    'ml': ScriptFamily.malayalam,
    'or': ScriptFamily.odia,
    'si': ScriptFamily.sinhala,
    'th': ScriptFamily.thai,
    'lo': ScriptFamily.lao,
    'km': ScriptFamily.khmer,
    'my': ScriptFamily.myanmar,
    'zh': ScriptFamily.cjk,
    'ja': ScriptFamily.cjk,
    'ko': ScriptFamily.cjk,
    'am': ScriptFamily.ethiopic,
    'hy': ScriptFamily.armenian,
    'ka': ScriptFamily.georgian,
    'dv': ScriptFamily.thaana,
  };

  static const Map<ScriptFamily, List<String>> _fallbacks =
      <ScriptFamily, List<String>>{
    ScriptFamily.latin: <String>[
      'Roboto',
      'Noto Sans',
      'Arial',
      'Helvetica',
      'sans-serif',
    ],
    ScriptFamily.cyrillic: <String>[
      'Roboto',
      'Noto Sans',
      'Arial',
      'Helvetica',
      'sans-serif',
    ],
    ScriptFamily.greek: <String>[
      'Roboto',
      'Noto Sans',
      'Arial',
      'Helvetica',
      'sans-serif',
    ],
    ScriptFamily.arabic: <String>[
      'Noto Sans Arabic',
      'Noto Naskh Arabic',
      'Geeza Pro',
      'Arial',
      'sans-serif',
    ],
    ScriptFamily.devanagari: <String>[
      'Noto Sans Devanagari',
      'Noto Serif Devanagari',
      'Kohinoor Devanagari',
      'Mangal',
      'sans-serif',
    ],
    ScriptFamily.bengali: <String>[
      'Noto Sans Bengali',
      'Kohinoor Bangla',
      'Vrinda',
      'sans-serif',
    ],
    ScriptFamily.gurmukhi: <String>[
      'Noto Sans Gurmukhi',
      'Kohinoor Gurmukhi',
      'Raavi',
      'sans-serif',
    ],
    ScriptFamily.gujarati: <String>[
      'Noto Sans Gujarati',
      'Shruti',
      'Nirmala UI',
      'sans-serif',
    ],
    ScriptFamily.tamil: <String>[
      'Noto Sans Tamil',
      'Tamil Sangam MN',
      'Latha',
      'sans-serif',
    ],
    ScriptFamily.telugu: <String>[
      'Noto Sans Telugu',
      'Nirmala UI',
      'Gautami',
      'sans-serif',
    ],
    ScriptFamily.kannada: <String>[
      'Noto Sans Kannada',
      'Nirmala UI',
      'Tunga',
      'sans-serif',
    ],
    ScriptFamily.malayalam: <String>[
      'Noto Sans Malayalam',
      'Nirmala UI',
      'Kartika',
      'sans-serif',
    ],
    ScriptFamily.odia: <String>[
      'Noto Sans Oriya',
      'Nirmala UI',
      'Kalinga',
      'sans-serif',
    ],
    ScriptFamily.sinhala: <String>[
      'Noto Sans Sinhala',
      'Nirmala UI',
      'Iskoola Pota',
      'sans-serif',
    ],
    ScriptFamily.thai: <String>[
      'Noto Sans Thai',
      'Thonburi',
      'Tahoma',
      'sans-serif',
    ],
    ScriptFamily.lao: <String>[
      'Noto Sans Lao',
      'Phetsarath OT',
      'Leelawadee UI',
      'sans-serif',
    ],
    ScriptFamily.khmer: <String>[
      'Noto Sans Khmer',
      'Khmer Sangam MN',
      'Leelawadee UI',
      'sans-serif',
    ],
    ScriptFamily.myanmar: <String>[
      'Noto Sans Myanmar',
      'Myanmar Sangam MN',
      'Myanmar Text',
      'sans-serif',
    ],
    ScriptFamily.cjk: <String>[
      'Noto Sans CJK SC',
      'Noto Sans CJK TC',
      'Noto Sans CJK JP',
      'Noto Sans CJK KR',
      'Noto Sans SC',
      'Noto Sans TC',
      'Noto Sans JP',
      'Noto Sans KR',
      'PingFang SC',
      'Hiragino Sans',
      'Yu Gothic',
      'Malgun Gothic',
      'sans-serif',
    ],
    ScriptFamily.ethiopic: <String>[
      'Noto Sans Ethiopic',
      'Kefa',
      'Abyssinica SIL',
      'sans-serif',
    ],
    ScriptFamily.armenian: <String>[
      'Noto Sans Armenian',
      'Mshtakan',
      'Sylfaen',
      'sans-serif',
    ],
    ScriptFamily.georgian: <String>[
      'Noto Sans Georgian',
      'Noto Serif Georgian',
      'Sylfaen',
      'sans-serif',
    ],
    ScriptFamily.thaana: <String>[
      'Noto Sans Thaana',
      'Faruma',
      'MV Boli',
      'sans-serif',
    ],
  };

  /// Returns a copy of [baseStyle] with an ordered platform-font fallback
  /// chain appropriate for either an ISO/BCP-47 language code or an ISO 15924
  /// script code.
  static TextStyle getStyleForScript(
    String scriptCode, {
    TextStyle? baseStyle,
  }) {
    final family = _resolveScriptFamily(scriptCode);
    final scriptFallbacks =
        _fallbacks[family] ?? _fallbacks[ScriptFamily.latin]!;
    final existingFallbacks = baseStyle?.fontFamilyFallback ?? const <String>[];

    final mergedFallbacks = <String>[];
    for (final fontFamily in <String>[
      ...scriptFallbacks,
      ...existingFallbacks,
    ]) {
      if (!mergedFallbacks.contains(fontFamily)) {
        mergedFallbacks.add(fontFamily);
      }
    }

    return (baseStyle ?? const TextStyle()).copyWith(
      fontFamilyFallback: List<String>.unmodifiable(mergedFallbacks),
    );
  }

  /// Detects the default writing script for an ISO language code.
  ///
  /// Explicit BCP-47 script subtags take precedence, so values such as
  /// `sr-Latn` and `az-Arab` resolve correctly.
  static ScriptFamily detectScriptFamily(String languageCode) {
    return _resolveScriptFamily(languageCode);
  }

  static ScriptFamily _resolveScriptFamily(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('_', '-');
    if (normalized.isEmpty) {
      return ScriptFamily.latin;
    }

    final directScript = _scriptTags[normalized];
    if (directScript != null) {
      return directScript;
    }

    final parts = normalized.split('-');
    for (final part in parts.skip(1)) {
      final explicitScript = _scriptTags[part];
      if (explicitScript != null) {
        return explicitScript;
      }
    }

    return _languageScripts[parts.first] ?? ScriptFamily.latin;
  }
}
