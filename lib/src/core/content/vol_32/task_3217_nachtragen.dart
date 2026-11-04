// Sovereign Polyglot Core - Task 3217 (Academic Research)
class Task3217Engine {
  static const int taskId = 3217;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'nachtragen';
  static const String praeteritum = 'trug nach';
  static const String perfekt = 'hat nachgetragen';
  static const String arabicTranslation = 'تدقيق / متابعة المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[nachˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3217_nachtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt nachtragen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
