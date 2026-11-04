// Sovereign Polyglot Core - Task 3015 (Academic Research)
class Task3015Engine {
  static const int taskId = 3015;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'einstellen';
  static const String praeteritum = 'stellte ein';
  static const String perfekt = 'hat eingestellt';
  static const String arabicTranslation = 'إدراج / دمج التنظيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[einˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3015_einstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt einstellen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التنظيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
