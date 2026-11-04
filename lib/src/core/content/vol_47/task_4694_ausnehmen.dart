// Sovereign Polyglot Core - Task 4694 (Quality Assurance)
class Task4694Engine {
  static const int taskId = 4694;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ausnehmen';
  static const String praeteritum = 'nahm aus';
  static const String perfekt = 'hat ausgenommen';
  static const String arabicTranslation = 'توسيع / استخراج الاستلام (ضمان الجودة)';
  static const String ipaTranscription = '[ausˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4694_ausnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ausnehmen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الاستلام في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
