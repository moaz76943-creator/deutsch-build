// Sovereign Polyglot Core - Task 3823 (Financial Auditing)
class Task3823Engine {
  static const int taskId = 3823;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'entstellen';
  static const String praeteritum = 'entstellte';
  static const String perfekt = 'hat entstellt';
  static const String arabicTranslation = 'استخلاص / كشف التنظيم (التدقيق المالي)';
  static const String ipaTranscription = '[entˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3823_entstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung entstellen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التنظيم في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
