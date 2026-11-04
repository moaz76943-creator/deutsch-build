// Sovereign Polyglot Core - Task 4560 (Quality Assurance)
class Task4560Engine {
  static const int taskId = 4560;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ueberarbeiten';
  static const String praeteritum = 'ueberarbeitete';
  static const String perfekt = 'hat ueberarbeitet';
  static const String arabicTranslation = 'مراجعة / نقل العمل (ضمان الجودة)';
  static const String ipaTranscription = '[ueberˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4560_ueberarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ueberarbeiten.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل العمل في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
