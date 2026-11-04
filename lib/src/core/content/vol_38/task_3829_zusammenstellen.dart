// Sovereign Polyglot Core - Task 3829 (Financial Auditing)
class Task3829Engine {
  static const int taskId = 3829;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'zusammenstellen';
  static const String praeteritum = 'stellte zusammen';
  static const String perfekt = 'hat zusammengestellt';
  static const String arabicTranslation = 'تجميع / توحيد التنظيم (التدقيق المالي)';
  static const String ipaTranscription = '[zusammenˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3829_zusammenstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung zusammenstellen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التنظيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
