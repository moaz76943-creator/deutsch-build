// Sovereign Polyglot Core - Task 4991 (Civil Infrastructure)
class Task4991Engine {
  static const int taskId = 4991;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'abpruefen';
  static const String praeteritum = 'pruefte ab';
  static const String perfekt = 'hat abgeprueft';
  static const String arabicTranslation = 'فصل / إتمام التدقيق (الهندسة المدنية)';
  static const String ipaTranscription = '[abˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4991_abpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle abpruefen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التدقيق في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
