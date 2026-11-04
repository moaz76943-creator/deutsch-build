// Sovereign Polyglot Core - Task 4957 (Civil Infrastructure)
class Task4957Engine {
  static const int taskId = 4957;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'nacharbeiten';
  static const String praeteritum = 'arbeitete nach';
  static const String perfekt = 'hat nachgearbeitet';
  static const String arabicTranslation = 'تدقيق / متابعة العمل (الهندسة المدنية)';
  static const String ipaTranscription = '[nachˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4957_nacharbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle nacharbeiten.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة العمل في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
