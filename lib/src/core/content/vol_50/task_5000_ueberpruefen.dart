// Sovereign Polyglot Core - Task 5000 (Civil Infrastructure)
class Task5000Engine {
  static const int taskId = 5000;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'ueberpruefen';
  static const String praeteritum = 'ueberpruefte';
  static const String perfekt = 'hat ueberprueft';
  static const String arabicTranslation = 'مراجعة / نقل التدقيق (الهندسة المدنية)';
  static const String ipaTranscription = '[ueberˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_5000_ueberpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle ueberpruefen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التدقيق في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
