// Sovereign Polyglot Core - Task 2279 (Software Architecture)
class Task2279Engine {
  static const int taskId = 2279;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'zusetzen';
  static const String praeteritum = 'setzte zu';
  static const String perfekt = 'hat zugesetzt';
  static const String arabicTranslation = 'توجيه / إغلاق التنفيذ (هندسة البرمجيات)';
  static const String ipaTranscription = '[zuˈˈzɛtsn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2279_zusetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review zusetzen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التنفيذ في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
