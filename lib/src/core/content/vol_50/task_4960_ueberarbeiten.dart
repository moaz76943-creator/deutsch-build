// Sovereign Polyglot Core - Task 4960 (Civil Infrastructure)
class Task4960Engine {
  static const int taskId = 4960;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'ueberarbeiten';
  static const String praeteritum = 'ueberarbeitete';
  static const String perfekt = 'hat ueberarbeitet';
  static const String arabicTranslation = 'مراجعة / نقل العمل (الهندسة المدنية)';
  static const String ipaTranscription = '[ueberˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4960_ueberarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle ueberarbeiten.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل العمل في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
