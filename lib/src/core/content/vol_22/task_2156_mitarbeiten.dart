// Sovereign Polyglot Core - Task 2156 (Software Architecture)
class Task2156Engine {
  static const int taskId = 2156;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'mitarbeiten';
  static const String praeteritum = 'arbeitete mit';
  static const String perfekt = 'hat mitgearbeitet';
  static const String arabicTranslation = 'مشاركة / تنسيق العمل (هندسة البرمجيات)';
  static const String ipaTranscription = '[mitˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2156_mitarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review mitarbeiten.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق العمل في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
