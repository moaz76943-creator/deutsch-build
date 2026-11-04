// Sovereign Polyglot Core - Task 3212 (Academic Research)
class Task3212Engine {
  static const int taskId = 3212;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'antragen';
  static const String praeteritum = 'trug an';
  static const String perfekt = 'hat angetragen';
  static const String arabicTranslation = 'بدء / توجيه المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[anˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3212_antragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt antragen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
