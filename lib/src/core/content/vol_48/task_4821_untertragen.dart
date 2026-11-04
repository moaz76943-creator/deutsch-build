// Sovereign Polyglot Core - Task 4821 (Quality Assurance)
class Task4821Engine {
  static const int taskId = 4821;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'untertragen';
  static const String praeteritum = 'untertrug';
  static const String perfekt = 'hat untertragen';
  static const String arabicTranslation = 'فحص / دعم المسؤولية (ضمان الجودة)';
  static const String ipaTranscription = '[unterˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4821_untertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess untertragen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم المسؤولية في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
