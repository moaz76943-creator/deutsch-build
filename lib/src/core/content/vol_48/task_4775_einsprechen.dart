// Sovereign Polyglot Core - Task 4775 (Quality Assurance)
class Task4775Engine {
  static const int taskId = 4775;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'einsprechen';
  static const String praeteritum = 'sprach ein';
  static const String perfekt = 'hat eingesprochen';
  static const String arabicTranslation = 'إدراج / دمج التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[einˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4775_einsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess einsprechen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
