// Sovereign Polyglot Core - Task 2967 (Academic Research)
class Task2967Engine {
  static const int taskId = 2967;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'umarbeiten';
  static const String praeteritum = 'arbeitete um';
  static const String perfekt = 'hat umgearbeitet';
  static const String arabicTranslation = 'إعادة هيكلة العمل (البحث الأكاديمي)';
  static const String ipaTranscription = '[umˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2967_umarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt umarbeiten.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة العمل في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
