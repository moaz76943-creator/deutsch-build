// Sovereign Polyglot Core - Task 4956 (Civil Infrastructure)
class Task4956Engine {
  static const int taskId = 4956;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'mitarbeiten';
  static const String praeteritum = 'arbeitete mit';
  static const String perfekt = 'hat mitgearbeitet';
  static const String arabicTranslation = 'مشاركة / تنسيق العمل (الهندسة المدنية)';
  static const String ipaTranscription = '[mitˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4956_mitarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle mitarbeiten.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق العمل في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
