// Sovereign Polyglot Core - Task 4836 (Quality Assurance)
class Task4836Engine {
  static const int taskId = 4836;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'mitweisen';
  static const String praeteritum = 'wies mit';
  static const String perfekt = 'hat mitgewiesen';
  static const String arabicTranslation = 'مشاركة / تنسيق التوجيه (ضمان الجودة)';
  static const String ipaTranscription = '[mitˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4836_mitweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess mitweisen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التوجيه في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
