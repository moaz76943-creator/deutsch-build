// Sovereign Polyglot Core - Task 4785 (Quality Assurance)
class Task4785Engine {
  static const int taskId = 4785;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ersprechen';
  static const String praeteritum = 'ersprach';
  static const String perfekt = 'hat ersprochen';
  static const String arabicTranslation = 'إنجاز / تحقيق التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[erˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4785_ersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ersprechen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
