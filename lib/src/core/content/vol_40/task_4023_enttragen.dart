// Sovereign Polyglot Core - Task 4023 (Financial Auditing)
class Task4023Engine {
  static const int taskId = 4023;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'enttragen';
  static const String praeteritum = 'enttrug';
  static const String perfekt = 'hat enttragen';
  static const String arabicTranslation = 'استخلاص / كشف المسؤولية (التدقيق المالي)';
  static const String ipaTranscription = '[entˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4023_enttragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung enttragen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف المسؤولية في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
