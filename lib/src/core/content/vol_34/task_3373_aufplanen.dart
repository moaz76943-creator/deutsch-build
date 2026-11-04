// Sovereign Polyglot Core - Task 3373 (Contractual Compliance)
class Task3373Engine {
  static const int taskId = 3373;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'aufplanen';
  static const String praeteritum = 'plante auf';
  static const String perfekt = 'hat aufgeplant';
  static const String arabicTranslation = 'رفع / فتح التخطيط (العقود والإدارة)';
  static const String ipaTranscription = '[aufˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3373_aufplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung aufplanen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التخطيط أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
