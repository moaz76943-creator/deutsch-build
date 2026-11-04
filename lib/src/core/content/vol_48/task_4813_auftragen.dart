// Sovereign Polyglot Core - Task 4813 (Quality Assurance)
class Task4813Engine {
  static const int taskId = 4813;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'auftragen';
  static const String praeteritum = 'trug auf';
  static const String perfekt = 'hat aufgetragen';
  static const String arabicTranslation = 'رفع / فتح المسؤولية (ضمان الجودة)';
  static const String ipaTranscription = '[aufˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4813_auftragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess auftragen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح المسؤولية في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
