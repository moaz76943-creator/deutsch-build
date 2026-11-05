// Sovereign Nominal Core - Task 2184
class Task2184Engine {
  static const int taskId = 2184;
  static const String identifier = 'zielvereinbarung';
  static const String germanNoun = 'die Zielvereinbarung';
  static const String arabicTranslation = 'اتفاقية تحديد الأهداف المهنية';
  static const String ipaTranscription = '[ˈtsiːlfɛɐ̯ˌʔaɪ̯nbaːʁʊŋ]';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/nouns/task_2184_zielvereinbarung.ogg';
  static const String exampleGerman = 'Die Zielvereinbarung wurde unterzeichnet.';
  static const String exampleArabic = 'تم توقيع اتفاقية الأهداف.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'noun': germanNoun,
    'arabic': arabicTranslation, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => germanNoun.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
