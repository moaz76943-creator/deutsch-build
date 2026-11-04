// Sovereign Polyglot Core - Task 3551 (Contractual Compliance)
class Task3551Engine {
  static const int taskId = 3551;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'abschreiben';
  static const String praeteritum = 'schrieb ab';
  static const String perfekt = 'hat abgeschrieben';
  static const String arabicTranslation = 'فصل / إتمام التدوين (العقود والإدارة)';
  static const String ipaTranscription = '[abˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3551_abschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung abschreiben.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التدوين أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
