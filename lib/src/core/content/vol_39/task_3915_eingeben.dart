// Sovereign Polyglot Core - Task 3915 (Financial Auditing)
class Task3915Engine {
  static const int taskId = 3915;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'eingeben';
  static const String praeteritum = 'gab ein';
  static const String perfekt = 'hat eingegeben';
  static const String arabicTranslation = 'إدراج / دمج التسليم (التدقيق المالي)';
  static const String ipaTranscription = '[einˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3915_eingeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung eingeben.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التسليم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
