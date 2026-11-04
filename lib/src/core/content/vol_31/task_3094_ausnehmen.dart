// Sovereign Polyglot Core - Task 3094 (Academic Research)
class Task3094Engine {
  static const int taskId = 3094;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ausnehmen';
  static const String praeteritum = 'nahm aus';
  static const String perfekt = 'hat ausgenommen';
  static const String arabicTranslation = 'توسيع / استخراج الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[ausˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3094_ausnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ausnehmen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
