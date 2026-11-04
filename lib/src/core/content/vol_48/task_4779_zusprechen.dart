// Sovereign Polyglot Core - Task 4779 (Quality Assurance)
class Task4779Engine {
  static const int taskId = 4779;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'zusprechen';
  static const String praeteritum = 'sprach zu';
  static const String perfekt = 'hat zugesprochen';
  static const String arabicTranslation = 'توجيه / إغلاق التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[zuˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4779_zusprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess zusprechen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
