// Sovereign Polyglot Core - Task 3003 (Academic Research)
class Task3003Engine {
  static const int taskId = 3003;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'entpruefen';
  static const String praeteritum = 'entpruefte';
  static const String perfekt = 'hat entprueft';
  static const String arabicTranslation = 'استخلاص / كشف التدقيق (البحث الأكاديمي)';
  static const String ipaTranscription = '[entˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3003_entpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt entpruefen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التدقيق في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
