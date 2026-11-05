// Sovereign Nominal Core - Task 2188
class Task2188Engine {
  static const int taskId = 2188;
  static const String identifier = 'kostenrechnung';
  static const String germanNoun = 'die Kostenrechnung';
  static const String arabicTranslation = 'محاسبة التكاليف والموازنة';
  static const String ipaTranscription = '[ˈkɔstn̩ˌʁɛçnʊŋ]';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/nouns/task_2188_kostenrechnung.ogg';
  static const String exampleGerman = 'Die Kostenrechnung ist transparent.';
  static const String exampleArabic = 'حساب التكاليف شفاف وموثق.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'noun': germanNoun,
    'arabic': arabicTranslation, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => germanNoun.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
