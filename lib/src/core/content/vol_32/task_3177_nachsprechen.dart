// Sovereign Polyglot Core - Task 3177 (Academic Research)
class Task3177Engine {
  static const int taskId = 3177;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'nachsprechen';
  static const String praeteritum = 'sprach nach';
  static const String perfekt = 'hat nachgesprochen';
  static const String arabicTranslation = 'تدقيق / متابعة التخاطب (البحث الأكاديمي)';
  static const String ipaTranscription = '[nachˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3177_nachsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt nachsprechen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التخاطب في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
