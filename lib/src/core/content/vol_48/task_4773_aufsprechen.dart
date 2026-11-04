// Sovereign Polyglot Core - Task 4773 (Quality Assurance)
class Task4773Engine {
  static const int taskId = 4773;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'aufsprechen';
  static const String praeteritum = 'sprach auf';
  static const String perfekt = 'hat aufgesprochen';
  static const String arabicTranslation = 'رفع / فتح التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[aufˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4773_aufsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess aufsprechen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
