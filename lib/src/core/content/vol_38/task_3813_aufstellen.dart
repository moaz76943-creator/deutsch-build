// Sovereign Polyglot Core - Task 3813 (Financial Auditing)
class Task3813Engine {
  static const int taskId = 3813;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'aufstellen';
  static const String praeteritum = 'stellte auf';
  static const String perfekt = 'hat aufgestellt';
  static const String arabicTranslation = 'رفع / فتح التنظيم (التدقيق المالي)';
  static const String ipaTranscription = '[aufˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3813_aufstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung aufstellen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التنظيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
