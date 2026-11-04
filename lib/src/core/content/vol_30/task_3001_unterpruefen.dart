// Sovereign Polyglot Core - Task 3001 (Academic Research)
class Task3001Engine {
  static const int taskId = 3001;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'unterpruefen';
  static const String praeteritum = 'unterpruefte';
  static const String perfekt = 'hat unterprueft';
  static const String arabicTranslation = 'فحص / دعم التدقيق (البحث الأكاديمي)';
  static const String ipaTranscription = '[unterˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3001_unterpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt unterpruefen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التدقيق في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
