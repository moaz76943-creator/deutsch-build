// Sovereign Polyglot Core - Task 3081 (Academic Research)
class Task3081Engine {
  static const int taskId = 3081;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'untersetzen';
  static const String praeteritum = 'untersetzte';
  static const String perfekt = 'hat untersetzt';
  static const String arabicTranslation = 'فحص / دعم التنفيذ (البحث الأكاديمي)';
  static const String ipaTranscription = '[unterˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3081_untersetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt untersetzen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التنفيذ في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
