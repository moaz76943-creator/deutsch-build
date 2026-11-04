// Sovereign Polyglot Core - Task 3228 (Academic Research)
class Task3228Engine {
  static const int taskId = 3228;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'weitertragen';
  static const String praeteritum = 'trug weiter';
  static const String perfekt = 'hat weitergetragen';
  static const String arabicTranslation = 'مواصلة / تمرير المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[weiterˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3228_weitertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt weitertragen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
