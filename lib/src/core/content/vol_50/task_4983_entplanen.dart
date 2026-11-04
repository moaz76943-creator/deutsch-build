// Sovereign Polyglot Core - Task 4983 (Civil Infrastructure)
class Task4983Engine {
  static const int taskId = 4983;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'entplanen';
  static const String praeteritum = 'entplante';
  static const String perfekt = 'hat entplant';
  static const String arabicTranslation = 'استخلاص / كشف التخطيط (الهندسة المدنية)';
  static const String ipaTranscription = '[entˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4983_entplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle entplanen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التخطيط في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
