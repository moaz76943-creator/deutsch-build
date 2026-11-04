// Sovereign Polyglot Core - Task 3790 (Financial Auditing)
class Task3790Engine {
  static const int taskId = 3790;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'festplanen';
  static const String praeteritum = 'plante fest';
  static const String perfekt = 'hat festgeplant';
  static const String arabicTranslation = 'تثبيت / إقرار التخطيط (التدقيق المالي)';
  static const String ipaTranscription = '[festˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3790_festplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung festplanen.';
  static const String exampleArabic = 'يجب علينا تثبيت / إقرار التخطيط في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
