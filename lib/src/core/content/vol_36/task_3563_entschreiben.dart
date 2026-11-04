// Sovereign Polyglot Core - Task 3563 (Contractual Compliance)
class Task3563Engine {
  static const int taskId = 3563;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entschreiben';
  static const String praeteritum = 'entschrieb';
  static const String perfekt = 'hat entschrieben';
  static const String arabicTranslation = 'استخلاص / كشف التدوين (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3563_entschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entschreiben.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التدوين أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
