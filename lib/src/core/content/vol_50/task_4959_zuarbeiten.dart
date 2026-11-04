// Sovereign Polyglot Core - Task 4959 (Civil Infrastructure)
class Task4959Engine {
  static const int taskId = 4959;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'zuarbeiten';
  static const String praeteritum = 'arbeitete zu';
  static const String perfekt = 'hat zugearbeitet';
  static const String arabicTranslation = 'توجيه / إغلاق العمل (الهندسة المدنية)';
  static const String ipaTranscription = '[zuˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4959_zuarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle zuarbeiten.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق العمل في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
