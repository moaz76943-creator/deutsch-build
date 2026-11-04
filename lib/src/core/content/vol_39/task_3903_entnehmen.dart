// Sovereign Polyglot Core - Task 3903 (Financial Auditing)
class Task3903Engine {
  static const int taskId = 3903;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'entnehmen';
  static const String praeteritum = 'entnahm';
  static const String perfekt = 'hat entnommen';
  static const String arabicTranslation = 'استخلاص / كشف الاستلام (التدقيق المالي)';
  static const String ipaTranscription = '[entˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3903_entnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung entnehmen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الاستلام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
