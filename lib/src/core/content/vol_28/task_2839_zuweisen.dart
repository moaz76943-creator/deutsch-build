// Sovereign Polyglot Core - Task 2839 (Clinical Diagnostics)
class Task2839Engine {
  static const int taskId = 2839;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zuweisen';
  static const String praeteritum = 'wies zu';
  static const String perfekt = 'hat zugewiesen';
  static const String arabicTranslation = 'توجيه / إغلاق التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[zuˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2839_zuweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zuweisen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
