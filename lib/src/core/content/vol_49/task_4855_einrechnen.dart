// Sovereign Polyglot Core - Task 4855 (Quality Assurance)
class Task4855Engine {
  static const int taskId = 4855;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'einrechnen';
  static const String praeteritum = 'rechnete ein';
  static const String perfekt = 'hat eingerechnet';
  static const String arabicTranslation = 'إدراج / دمج التقدير (ضمان الجودة)';
  static const String ipaTranscription = '[einˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4855_einrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess einrechnen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التقدير في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
