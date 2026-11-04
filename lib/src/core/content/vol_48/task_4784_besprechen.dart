// Sovereign Polyglot Core - Task 4784 (Quality Assurance)
class Task4784Engine {
  static const int taskId = 4784;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'besprechen';
  static const String praeteritum = 'besprach';
  static const String perfekt = 'hat besprochen';
  static const String arabicTranslation = 'تأكيد / تزويد التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[beˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4784_besprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess besprechen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
