// Sovereign Polyglot Core - Task 2860 (Clinical Diagnostics)
class Task2860Engine {
  static const int taskId = 2860;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberrechnen';
  static const String praeteritum = 'ueberrechnete';
  static const String perfekt = 'hat ueberrechnet';
  static const String arabicTranslation = 'مراجعة / نقل التقدير (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2860_ueberrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberrechnen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التقدير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
