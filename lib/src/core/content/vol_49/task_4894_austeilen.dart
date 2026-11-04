// Sovereign Polyglot Core - Task 4894 (Quality Assurance)
class Task4894Engine {
  static const int taskId = 4894;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'austeilen';
  static const String praeteritum = 'teilte aus';
  static const String perfekt = 'hat ausgeteilt';
  static const String arabicTranslation = 'توسيع / استخراج التقسيم (ضمان الجودة)';
  static const String ipaTranscription = '[ausˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4894_austeilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess austeilen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التقسيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
