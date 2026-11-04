// Sovereign Polyglot Core - Task 3661 (Contractual Compliance)
class Task3661Engine {
  static const int taskId = 3661;
  static const String domain = 'Contractual Compliance';
  static const String verbInfinitive = 'unterrechnen';
  static const String praeteritum = 'unterrechnete';
  static const String perfekt = 'hat unterrechnet';
  static const String arabicTranslation = 'فحص / دعم التقدير (العقود والإدارة)';
  static const String ipaTranscription = '[unterˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_3661_unterrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess bei der Vertragspruefung unterrechnen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التقدير أثناء تدقيق العقود الرسمية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
