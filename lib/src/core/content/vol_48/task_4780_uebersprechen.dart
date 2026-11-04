// Sovereign Polyglot Core - Task 4780 (Quality Assurance)
class Task4780Engine {
  static const int taskId = 4780;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'uebersprechen';
  static const String praeteritum = 'uebersprach';
  static const String perfekt = 'hat uebersprochen';
  static const String arabicTranslation = 'مراجعة / نقل التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[ueberˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4780_uebersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess uebersprechen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
