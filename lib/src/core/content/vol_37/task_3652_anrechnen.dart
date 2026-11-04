// Sovereign Polyglot Core - Task 3652 (Contractual Compliance)
class Task3652Engine {
  static const int taskId = 3652;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'anrechnen';
  static const String praeteritum = 'rechnete an';
  static const String perfekt = 'hat angerechnet';
  static const String arabicTranslation = 'بدء / توجيه التقدير (العقود والإدارة)';
  static const String ipaTranscription = '[anˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3652_anrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung anrechnen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التقدير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
