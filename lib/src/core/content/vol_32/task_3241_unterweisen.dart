// Sovereign Polyglot Core - Task 3241 (Academic Research)
class Task3241Engine {
  static const int taskId = 3241;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'unterweisen';
  static const String praeteritum = 'unterwies';
  static const String perfekt = 'hat unterwiesen';
  static const String arabicTranslation = 'فحص / دعم التوجيه (البحث الأكاديمي)';
  static const String ipaTranscription = '[unterˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3241_unterweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt unterweisen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التوجيه في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
