// Sovereign Polyglot Core - Task 2815 (Clinical Diagnostics)
class Task2815Engine {
  static const int taskId = 2815;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'eintragen';
  static const String praeteritum = 'trug ein';
  static const String perfekt = 'hat eingetragen';
  static const String arabicTranslation = 'إدراج / دمج المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[einˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2815_eintragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung eintragen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
