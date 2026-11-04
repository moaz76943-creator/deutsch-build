// Sovereign Polyglot Core - Task 3223 (Academic Research)
class Task3223Engine {
  static const int taskId = 3223;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'enttragen';
  static const String praeteritum = 'enttrug';
  static const String perfekt = 'hat enttragen';
  static const String arabicTranslation = 'استخلاص / كشف المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[entˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3223_enttragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt enttragen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
