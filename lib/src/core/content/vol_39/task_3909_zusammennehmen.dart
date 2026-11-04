// Sovereign Polyglot Core - Task 3909 (Financial Auditing)
class Task3909Engine {
  static const int taskId = 3909;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'zusammennehmen';
  static const String praeteritum = 'nahm zusammen';
  static const String perfekt = 'hat zusammengenommen';
  static const String arabicTranslation = 'تجميع / توحيد الاستلام (التدقيق المالي)';
  static const String ipaTranscription = '[zusammenˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3909_zusammennehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung zusammennehmen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الاستلام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
