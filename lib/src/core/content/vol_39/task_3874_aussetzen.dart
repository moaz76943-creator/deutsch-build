// Sovereign Polyglot Core - Task 3874 (Financial Auditing)
class Task3874Engine {
  static const int taskId = 3874;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'aussetzen';
  static const String praeteritum = 'setzte aus';
  static const String perfekt = 'hat ausgesetzt';
  static const String arabicTranslation = 'توسيع / استخراج التنفيذ (التدقيق المالي)';
  static const String ipaTranscription = '[ausˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3874_aussetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung aussetzen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التنفيذ في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
