// Sovereign Polyglot Core - Task 4123 (Financial Auditing)
class Task4123Engine {
  static const int taskId = 4123;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'entschliessen';
  static const String praeteritum = 'entschloss';
  static const String perfekt = 'hat entschlossen';
  static const String arabicTranslation = 'استخلاص / كشف الإبرام (التدقيق المالي)';
  static const String ipaTranscription = '[entˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4123_entschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung entschliessen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الإبرام في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
