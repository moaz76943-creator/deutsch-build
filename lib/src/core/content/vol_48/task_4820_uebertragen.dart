// Sovereign Polyglot Core - Task 4820 (Quality Assurance)
class Task4820Engine {
  static const int taskId = 4820;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'uebertragen';
  static const String praeteritum = 'uebertrug';
  static const String perfekt = 'hat uebertragen';
  static const String arabicTranslation = 'مراجعة / نقل المسؤولية (ضمان الجودة)';
  static const String ipaTranscription = '[ueberˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4820_uebertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess uebertragen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل المسؤولية في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
