// Sovereign Polyglot Core - Task 3279 (Academic Research)
class Task3279Engine {
  static const int taskId = 3279;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zuordnen';
  static const String praeteritum = 'ordnete zu';
  static const String perfekt = 'hat zugeordnet';
  static const String arabicTranslation = 'توجيه / إغلاق التصنيف (البحث الأكاديمي)';
  static const String ipaTranscription = '[zuˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3279_zuordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zuordnen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التصنيف في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
