// Sovereign Polyglot Core - Task 3272 (Academic Research)
class Task3272Engine {
  static const int taskId = 3272;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'anordnen';
  static const String praeteritum = 'ordnete an';
  static const String perfekt = 'hat angeordnet';
  static const String arabicTranslation = 'بدء / توجيه التصنيف (البحث الأكاديمي)';
  static const String ipaTranscription = '[anˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3272_anordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt anordnen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التصنيف في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
