// Sovereign Polyglot Core - Task 3214 (Academic Research)
class Task3214Engine {
  static const int taskId = 3214;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'austragen';
  static const String praeteritum = 'trug aus';
  static const String perfekt = 'hat ausgetragen';
  static const String arabicTranslation = 'توسيع / استخراج المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[ausˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3214_austragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt austragen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
