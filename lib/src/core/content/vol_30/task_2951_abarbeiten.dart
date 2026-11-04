// Sovereign Polyglot Core - Task 2951 (Academic Research)
class Task2951Engine {
  static const int taskId = 2951;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abarbeiten';
  static const String praeteritum = 'arbeitete ab';
  static const String perfekt = 'hat abgearbeitet';
  static const String arabicTranslation = 'فصل / إتمام العمل (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2951_abarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abarbeiten.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام العمل في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
