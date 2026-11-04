// Sovereign Polyglot Core - Task 2579 (Clinical Diagnostics)
class Task2579Engine {
  static const int taskId = 2579;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zuplanen';
  static const String praeteritum = 'plante zu';
  static const String perfekt = 'hat zugeplant';
  static const String arabicTranslation = 'توجيه / إغلاق التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[zuˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2579_zuplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zuplanen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
