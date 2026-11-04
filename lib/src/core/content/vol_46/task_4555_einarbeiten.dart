// Sovereign Polyglot Core - Task 4555 (Quality Assurance)
class Task4555Engine {
  static const int taskId = 4555;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'einarbeiten';
  static const String praeteritum = 'arbeitete ein';
  static const String perfekt = 'hat eingearbeitet';
  static const String arabicTranslation = 'إدراج / دمج العمل (ضمان الجودة)';
  static const String ipaTranscription = '[einˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4555_einarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess einarbeiten.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج العمل في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
