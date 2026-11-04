// Sovereign Polyglot Core - Task 3226 (Academic Research)
class Task3226Engine {
  static const int taskId = 3226;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'durchtragen';
  static const String praeteritum = 'trug durch';
  static const String perfekt = 'hat durchgetragen';
  static const String arabicTranslation = 'إتمام شامل المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[durchˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3226_durchtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt durchtragen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
