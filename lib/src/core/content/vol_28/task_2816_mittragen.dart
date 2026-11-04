// Sovereign Polyglot Core - Task 2816 (Clinical Diagnostics)
class Task2816Engine {
  static const int taskId = 2816;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'mittragen';
  static const String praeteritum = 'trug mit';
  static const String perfekt = 'hat mitgetragen';
  static const String arabicTranslation = 'مشاركة / تنسيق المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[mitˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2816_mittragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung mittragen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
