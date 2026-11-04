// Sovereign Polyglot Core - Task 4829 (Quality Assurance)
class Task4829Engine {
  static const int taskId = 4829;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'zusammentragen';
  static const String praeteritum = 'trug zusammen';
  static const String perfekt = 'hat zusammengetragen';
  static const String arabicTranslation = 'تجميع / توحيد المسؤولية (ضمان الجودة)';
  static const String ipaTranscription = '[zusammenˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4829_zusammentragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess zusammentragen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد المسؤولية في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
