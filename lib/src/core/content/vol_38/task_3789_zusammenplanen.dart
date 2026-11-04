// Sovereign Polyglot Core - Task 3789 (Financial Auditing)
class Task3789Engine {
  static const int taskId = 3789;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'zusammenplanen';
  static const String praeteritum = 'plante zusammen';
  static const String perfekt = 'hat zusammengeplant';
  static const String arabicTranslation = 'تجميع / توحيد التخطيط (التدقيق المالي)';
  static const String ipaTranscription = '[zusammenˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3789_zusammenplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung zusammenplanen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التخطيط في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
