// Sovereign Polyglot Core - Task 3215 (Academic Research)
class Task3215Engine {
  static const int taskId = 3215;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'eintragen';
  static const String praeteritum = 'trug ein';
  static const String perfekt = 'hat eingetragen';
  static const String arabicTranslation = 'إدراج / دمج المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[einˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3215_eintragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt eintragen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
