// Sovereign Polyglot Core - Task 3229 (Academic Research)
class Task3229Engine {
  static const int taskId = 3229;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zusammentragen';
  static const String praeteritum = 'trug zusammen';
  static const String perfekt = 'hat zusammengetragen';
  static const String arabicTranslation = 'تجميع / توحيد المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[zusammenˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3229_zusammentragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zusammentragen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
