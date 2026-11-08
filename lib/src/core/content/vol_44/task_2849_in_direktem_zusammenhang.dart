// Sovereign Precision Operator Core - Task 2849
class Task2849Engine {
  static const int taskId = 2849;
  static const String identifier = 'in_direktem_zusammenhang';
  static const String precisionPhrase = 'in direktem Zusammenhang stehen';
  static const String arabicMeaning = 'يرتبط ارتباطاً سببياً ومباشراً بالنتيجة';
  static const String cefrLevel = 'B2';
  static const String semanticCategory = 'Kausale Verknüpfung';
  static const String audioAssetPath = 'assets/audio/precision/task_2849_in_direktem_zusammenhang.ogg';
  static const String exampleGerman = 'Der Durchsatz steht in direktem Zusammenhang mit der Blockgröße.';
  static const String exampleArabic = 'يرتبط معدل النقل ارتباطاً مباشراً بحجم الكتلة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': precisionPhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': semanticCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => precisionPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
