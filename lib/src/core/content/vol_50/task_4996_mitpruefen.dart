// Sovereign Polyglot Core - Task 4996 (Civil Infrastructure)
class Task4996Engine {
  static const int taskId = 4996;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'mitpruefen';
  static const String praeteritum = 'pruefte mit';
  static const String perfekt = 'hat mitgeprueft';
  static const String arabicTranslation = 'مشاركة / تنسيق التدقيق (الهندسة المدنية)';
  static const String ipaTranscription = '[mitˈˈpʁyːfn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4996_mitpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle mitpruefen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التدقيق في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
