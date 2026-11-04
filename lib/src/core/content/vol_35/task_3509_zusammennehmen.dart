// Sovereign Polyglot Core - Task 3509 (Contractual Compliance)
class Task3509Engine {
  static const int taskId = 3509;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'zusammennehmen';
  static const String praeteritum = 'nahm zusammen';
  static const String perfekt = 'hat zusammengenommen';
  static const String arabicTranslation = 'تجميع / توحيد الاستلام (العقود والإدارة)';
  static const String ipaTranscription = '[zusammenˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3509_zusammennehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung zusammennehmen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد الاستلام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
