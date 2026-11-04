// Sovereign Polyglot Core - Task 3773 (Financial Auditing)
class Task3773Engine {
  static const int taskId = 3773;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'aufplanen';
  static const String praeteritum = 'plante auf';
  static const String perfekt = 'hat aufgeplant';
  static const String arabicTranslation = 'رفع / فتح التخطيط (التدقيق المالي)';
  static const String ipaTranscription = '[aufˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3773_aufplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung aufplanen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التخطيط في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
