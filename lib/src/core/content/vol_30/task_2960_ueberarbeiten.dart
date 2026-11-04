// Sovereign Polyglot Core - Task 2960 (Academic Research)
class Task2960Engine {
  static const int taskId = 2960;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ueberarbeiten';
  static const String praeteritum = 'ueberarbeitete';
  static const String perfekt = 'hat ueberarbeitet';
  static const String arabicTranslation = 'مراجعة / نقل العمل (البحث الأكاديمي)';
  static const String ipaTranscription = '[ueberˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2960_ueberarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ueberarbeiten.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل العمل في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
