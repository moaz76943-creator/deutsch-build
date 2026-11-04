// Sovereign Polyglot Core - Task 3281 (Academic Research)
class Task3281Engine {
  static const int taskId = 3281;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'unterordnen';
  static const String praeteritum = 'unterordnete';
  static const String perfekt = 'hat unterordnet';
  static const String arabicTranslation = 'فحص / دعم التصنيف (البحث الأكاديمي)';
  static const String ipaTranscription = '[unterˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3281_unterordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt unterordnen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التصنيف في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
