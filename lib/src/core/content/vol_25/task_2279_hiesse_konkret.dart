// Sovereign Diplomatic Konjunktiv Core - Task 2279
class Task2279Engine {
  static const int taskId = 2279;
  static const String identifier = 'hiesse_konkret';
  static const String phraseGerman = 'das hieße konkret';
  static const String arabicMeaning = 'سيعني ذلك على أرض الواقع';
  static const String ipaTranscription = '[das ˈhiːsə kɔŋˈkʁeːt]';
  static const String cefrLevel = 'B2';
  static const String pragmaticFunction = 'Schlussfolgerung';
  static const String audioAssetPath = 'assets/audio/konj2/task_2279_hiesse_konkret.ogg';
  static const String exampleGerman = 'Das hieße konkret: Fristen verkürzen.';
  static const String exampleArabic = 'سيعني ذلك تحديداً: تقليص المهل الزمنية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': phraseGerman,
    'arabic': arabicMeaning, 'ipa': ipaTranscription, 'cefr': cefrLevel,
    'function': pragmaticFunction, 'audio': audioAssetPath,
    'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => phraseGerman.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
