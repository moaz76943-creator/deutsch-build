// Sovereign Polyglot Core - Task 2788 (Clinical Diagnostics)
class Task2788Engine {
  static const int taskId = 2788;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'weitersprechen';
  static const String praeteritum = 'sprach weiter';
  static const String perfekt = 'hat weitergesprochen';
  static const String arabicTranslation = 'مواصلة / تمرير التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[weiterˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2788_weitersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung weitersprechen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
