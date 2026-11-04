// Sovereign Polyglot Core - Task 3575 (Contractual Compliance)
class Task3575Engine {
  static const int taskId = 3575;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'einsprechen';
  static const String praeteritum = 'sprach ein';
  static const String perfekt = 'hat eingesprochen';
  static const String arabicTranslation = 'إدراج / دمج التخاطب (العقود والإدارة)';
  static const String ipaTranscription = '[einˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3575_einsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung einsprechen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التخاطب أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
