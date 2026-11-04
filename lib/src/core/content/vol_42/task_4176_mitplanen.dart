// Sovereign Polyglot Core - Task 4176 (Supply Chain)
class Task4176Engine {
  static const int taskId = 4176;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'mitplanen';
  static const String praeteritum = 'plante mit';
  static const String perfekt = 'hat mitgeplant';
  static const String arabicTranslation = 'مشاركة / تنسيق التخطيط (سلاسل الإمداد)';
  static const String ipaTranscription = '[mitˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4176_mitplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale mitplanen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التخطيط في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
