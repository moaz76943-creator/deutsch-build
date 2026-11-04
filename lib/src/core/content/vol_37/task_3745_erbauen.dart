// Sovereign Polyglot Core - Task 3745 (Contractual Compliance)
class Task3745Engine {
  static const int taskId = 3745;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'erbauen';
  static const String praeteritum = 'erbaute';
  static const String perfekt = 'hat erbaut';
  static const String arabicTranslation = 'إنجاز / تحقيق التطوير (العقود والإدارة)';
  static const String ipaTranscription = '[erˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3745_erbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung erbauen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التطوير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
