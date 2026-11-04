// Sovereign Polyglot Core - Task 4790 (Quality Assurance)
class Task4790Engine {
  static const int taskId = 4790;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'festsprechen';
  static const String praeteritum = 'sprach fest';
  static const String perfekt = 'hat festgesprochen';
  static const String arabicTranslation = 'تثبيت / إقرار التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[festˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4790_festsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess festsprechen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
