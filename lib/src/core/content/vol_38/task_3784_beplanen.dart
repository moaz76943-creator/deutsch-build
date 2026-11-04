// Sovereign Polyglot Core - Task 3784 (Financial Auditing)
class Task3784Engine {
  static const int taskId = 3784;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'beplanen';
  static const String praeteritum = 'beplante';
  static const String perfekt = 'hat beplant';
  static const String arabicTranslation = 'تأكيد / تزويد التخطيط (التدقيق المالي)';
  static const String ipaTranscription = '[beˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3784_beplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung beplanen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التخطيط في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
