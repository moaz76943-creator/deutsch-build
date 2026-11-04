// Sovereign Polyglot Core - Task 3092 (Academic Research)
class Task3092Engine {
  static const int taskId = 3092;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'annehmen';
  static const String praeteritum = 'nahm an';
  static const String perfekt = 'hat angenommen';
  static const String arabicTranslation = 'بدء / توجيه الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[anˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3092_annehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt annehmen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
