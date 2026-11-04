// Sovereign Polyglot Core - Task 4787 (Quality Assurance)
class Task4787Engine {
  static const int taskId = 4787;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'umsprechen';
  static const String praeteritum = 'sprach um';
  static const String perfekt = 'hat umgesprochen';
  static const String arabicTranslation = 'إعادة هيكلة التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[umˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4787_umsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess umsprechen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
