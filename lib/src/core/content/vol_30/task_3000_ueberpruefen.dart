// Sovereign Polyglot Core - Task 3000 (Academic Research)
class Task3000Engine {
  static const int taskId = 3000;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ueberpruefen';
  static const String praeteritum = 'ueberpruefte';
  static const String perfekt = 'hat ueberprueft';
  static const String arabicTranslation = 'مراجعة / نقل التدقيق (البحث الأكاديمي)';
  static const String ipaTranscription = '[ueberˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3000_ueberpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ueberpruefen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التدقيق في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
