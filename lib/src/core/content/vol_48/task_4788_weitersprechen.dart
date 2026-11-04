// Sovereign Polyglot Core - Task 4788 (Quality Assurance)
class Task4788Engine {
  static const int taskId = 4788;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'weitersprechen';
  static const String praeteritum = 'sprach weiter';
  static const String perfekt = 'hat weitergesprochen';
  static const String arabicTranslation = 'مواصلة / تمرير التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[weiterˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4788_weitersprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess weitersprechen.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
