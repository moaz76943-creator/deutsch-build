// Sovereign Polyglot Core - Task 3180 (Academic Research)
class Task3180Engine {
  static const int taskId = 3180;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'uebersprechen';
  static const String praeteritum = 'uebersprach';
  static const String perfekt = 'hat uebersprochen';
  static const String arabicTranslation = 'مراجعة / نقل التخاطب (البحث الأكاديمي)';
  static const String ipaTranscription = '[ueberˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3180_uebersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt uebersprechen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التخاطب في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
