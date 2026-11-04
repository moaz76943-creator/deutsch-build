// Sovereign Polyglot Core - Task 2780 (Clinical Diagnostics)
class Task2780Engine {
  static const int taskId = 2780;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'uebersprechen';
  static const String praeteritum = 'uebersprach';
  static const String perfekt = 'hat uebersprochen';
  static const String arabicTranslation = 'مراجعة / نقل التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2780_uebersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung uebersprechen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
