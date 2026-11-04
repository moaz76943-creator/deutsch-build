// Sovereign Polyglot Core - Task 4774 (Quality Assurance)
class Task4774Engine {
  static const int taskId = 4774;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'aussprechen';
  static const String praeteritum = 'sprach aus';
  static const String perfekt = 'hat ausgesprochen';
  static const String arabicTranslation = 'توسيع / استخراج التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[ausˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4774_aussprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess aussprechen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
