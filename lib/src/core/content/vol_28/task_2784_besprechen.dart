// Sovereign Polyglot Core - Task 2784 (Clinical Diagnostics)
class Task2784Engine {
  static const int taskId = 2784;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'besprechen';
  static const String praeteritum = 'besprach';
  static const String perfekt = 'hat besprochen';
  static const String arabicTranslation = 'تأكيد / تزويد التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2784_besprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung besprechen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
