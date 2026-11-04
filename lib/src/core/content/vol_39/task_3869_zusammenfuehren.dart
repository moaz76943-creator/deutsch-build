// Sovereign Polyglot Core - Task 3869 (Financial Auditing)
class Task3869Engine {
  static const int taskId = 3869;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'zusammenfuehren';
  static const String praeteritum = 'fuehrte zusammen';
  static const String perfekt = 'hat zusammengefuehrt';
  static const String arabicTranslation = 'تجميع / توحيد الإدارة (التدقيق المالي)';
  static const String ipaTranscription = '[zusammenˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3869_zusammenfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung zusammenfuehren.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الإدارة في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
