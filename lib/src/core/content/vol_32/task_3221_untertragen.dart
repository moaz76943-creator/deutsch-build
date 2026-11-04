// Sovereign Polyglot Core - Task 3221 (Academic Research)
class Task3221Engine {
  static const int taskId = 3221;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'untertragen';
  static const String praeteritum = 'untertrug';
  static const String perfekt = 'hat untertragen';
  static const String arabicTranslation = 'فحص / دعم المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[unterˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3221_untertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt untertragen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
