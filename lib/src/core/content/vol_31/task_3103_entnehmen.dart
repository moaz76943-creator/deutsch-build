// Sovereign Polyglot Core - Task 3103 (Academic Research)
class Task3103Engine {
  static const int taskId = 3103;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'entnehmen';
  static const String praeteritum = 'entnahm';
  static const String perfekt = 'hat entnommen';
  static const String arabicTranslation = 'استخلاص / كشف الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[entˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3103_entnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt entnehmen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
