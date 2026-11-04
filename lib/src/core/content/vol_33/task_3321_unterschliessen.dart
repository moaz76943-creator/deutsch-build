// Sovereign Polyglot Core - Task 3321 (Academic Research)
class Task3321Engine {
  static const int taskId = 3321;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'unterschliessen';
  static const String praeteritum = 'unterschloss';
  static const String perfekt = 'hat unterschlossen';
  static const String arabicTranslation = 'فحص / دعم الإبرام (البحث الأكاديمي)';
  static const String ipaTranscription = '[unterˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3321_unterschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt unterschliessen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الإبرام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
