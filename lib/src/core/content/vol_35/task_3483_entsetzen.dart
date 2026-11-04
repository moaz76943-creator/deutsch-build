// Sovereign Polyglot Core - Task 3483 (Contractual Compliance)
class Task3483Engine {
  static const int taskId = 3483;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entsetzen';
  static const String praeteritum = 'entsetzte';
  static const String perfekt = 'hat entsetzt';
  static const String arabicTranslation = 'استخلاص / كشف التنفيذ (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3483_entsetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entsetzen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التنفيذ أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
