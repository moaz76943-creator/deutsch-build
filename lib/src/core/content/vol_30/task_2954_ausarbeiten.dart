// Sovereign Polyglot Core - Task 2954 (Academic Research)
class Task2954Engine {
  static const int taskId = 2954;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ausarbeiten';
  static const String praeteritum = 'arbeitete aus';
  static const String perfekt = 'hat ausgearbeitet';
  static const String arabicTranslation = 'توسيع / استخراج العمل (البحث الأكاديمي)';
  static const String ipaTranscription = '[ausˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2954_ausarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ausarbeiten.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج العمل في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
