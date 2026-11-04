// Sovereign Polyglot Core - Task 3767 (Financial Auditing)
class Task3767Engine {
  static const int taskId = 3767;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'umarbeiten';
  static const String praeteritum = 'arbeitete um';
  static const String perfekt = 'hat umgearbeitet';
  static const String arabicTranslation = 'إعادة هيكلة العمل (التدقيق المالي)';
  static const String ipaTranscription = '[umˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3767_umarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung umarbeiten.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة العمل في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
