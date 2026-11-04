// Sovereign Polyglot Core - Task 3004 (Academic Research)
class Task3004Engine {
  static const int taskId = 3004;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'bepruefen';
  static const String praeteritum = 'bepruefte';
  static const String perfekt = 'hat beprueft';
  static const String arabicTranslation = 'تأكيد / تزويد التدقيق (البحث الأكاديمي)';
  static const String ipaTranscription = '[beˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3004_bepruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt bepruefen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التدقيق في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
