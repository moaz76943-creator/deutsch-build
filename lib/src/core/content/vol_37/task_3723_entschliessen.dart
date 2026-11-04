// Sovereign Polyglot Core - Task 3723 (Contractual Compliance)
class Task3723Engine {
  static const int taskId = 3723;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entschliessen';
  static const String praeteritum = 'entschloss';
  static const String perfekt = 'hat entschlossen';
  static const String arabicTranslation = 'استخلاص / كشف الإبرام (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3723_entschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entschliessen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الإبرام أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
