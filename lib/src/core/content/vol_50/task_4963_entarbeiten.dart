// Sovereign Polyglot Core - Task 4963 (Civil Infrastructure)
class Task4963Engine {
  static const int taskId = 4963;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'entarbeiten';
  static const String praeteritum = 'entarbeitete';
  static const String perfekt = 'hat entarbeitet';
  static const String arabicTranslation = 'استخلاص / كشف العمل (الهندسة المدنية)';
  static const String ipaTranscription = '[entˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4963_entarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle entarbeiten.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف العمل في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
