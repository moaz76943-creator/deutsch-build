// Sovereign Polyglot Core - Task 3583 (Contractual Compliance)
class Task3583Engine {
  static const int taskId = 3583;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'entsprechen';
  static const String praeteritum = 'entsprach';
  static const String perfekt = 'hat entsprochen';
  static const String arabicTranslation = 'استخلاص / كشف التخاطب (العقود والإدارة)';
  static const String ipaTranscription = '[entˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3583_entsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung entsprechen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التخاطب أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
