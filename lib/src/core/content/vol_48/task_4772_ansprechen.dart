// Sovereign Polyglot Core - Task 4772 (Quality Assurance)
class Task4772Engine {
  static const int taskId = 4772;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ansprechen';
  static const String praeteritum = 'sprach an';
  static const String perfekt = 'hat angesprochen';
  static const String arabicTranslation = 'بدء / توجيه التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[anˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4772_ansprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ansprechen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
