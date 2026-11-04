// Sovereign Polyglot Core - Task 4979 (Civil Infrastructure)
class Task4979Engine {
  static const int taskId = 4979;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'zuplanen';
  static const String praeteritum = 'plante zu';
  static const String perfekt = 'hat zugeplant';
  static const String arabicTranslation = 'توجيه / إغلاق التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[zuˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4979_zuplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle zuplanen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
