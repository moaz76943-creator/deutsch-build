// Sovereign Polyglot Core - Task 3814 (Financial Auditing)
class Task3814Engine {
  static const int taskId = 3814;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'ausstellen';
  static const String praeteritum = 'stellte aus';
  static const String perfekt = 'hat ausgestellt';
  static const String arabicTranslation = 'توسيع / استخراج التنظيم (التدقيق المالي)';
  static const String ipaTranscription = '[ausˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3814_ausstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung ausstellen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التنظيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
