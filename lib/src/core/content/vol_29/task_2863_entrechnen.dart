// Sovereign Polyglot Core - Task 2863 (Clinical Diagnostics)
class Task2863Engine {
  static const int taskId = 2863;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'entrechnen';
  static const String praeteritum = 'entrechnete';
  static const String perfekt = 'hat entrechnet';
  static const String arabicTranslation = 'استخلاص / كشف التقدير (التواصل الطبي)';
  static const String ipaTranscription = '[entˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2863_entrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung entrechnen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التقدير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
