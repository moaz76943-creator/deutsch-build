// Sovereign Polyglot Core - Task 3093 (Academic Research)
class Task3093Engine {
  static const int taskId = 3093;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufnehmen';
  static const String praeteritum = 'nahm auf';
  static const String perfekt = 'hat aufgenommen';
  static const String arabicTranslation = 'رفع / فتح الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3093_aufnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufnehmen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
