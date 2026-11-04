// Sovereign Polyglot Core - Task 3779 (Financial Auditing)
class Task3779Engine {
  static const int taskId = 3779;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'zuplanen';
  static const String praeteritum = 'plante zu';
  static const String perfekt = 'hat zugeplant';
  static const String arabicTranslation = 'توجيه / إغلاق التخطيط (التدقيق المالي)';
  static const String ipaTranscription = '[zuˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3779_zuplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung zuplanen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التخطيط في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
