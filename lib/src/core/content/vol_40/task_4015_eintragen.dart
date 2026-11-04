// Sovereign Polyglot Core - Task 4015 (Financial Auditing)
class Task4015Engine {
  static const int taskId = 4015;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'eintragen';
  static const String praeteritum = 'trug ein';
  static const String perfekt = 'hat eingetragen';
  static const String arabicTranslation = 'إدراج / دمج المسؤولية (التدقيق المالي)';
  static const String ipaTranscription = '[einˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4015_eintragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung eintragen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج المسؤولية في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
