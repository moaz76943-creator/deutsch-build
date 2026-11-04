// Sovereign Polyglot Core - Task 2179 (Software Architecture)
class Task2179Engine {
  static const int taskId = 2179;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zuplanen';
  static const String praeteritum = 'plante zu';
  static const String perfekt = 'hat zugeplant';
  static const String arabicTranslation = 'توجيه / إغلاق التخطيط (هندسة البرمجيات)';
  static const String ipaTranscription = '[zuˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2179_zuplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zuplanen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التخطيط في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
