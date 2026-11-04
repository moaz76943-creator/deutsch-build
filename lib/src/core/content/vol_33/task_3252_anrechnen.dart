// Sovereign Polyglot Core - Task 3252 (Academic Research)
class Task3252Engine {
  static const int taskId = 3252;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'anrechnen';
  static const String praeteritum = 'rechnete an';
  static const String perfekt = 'hat angerechnet';
  static const String arabicTranslation = 'بدء / توجيه التقدير (البحث الأكاديمي)';
  static const String ipaTranscription = '[anˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3252_anrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt anrechnen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التقدير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
