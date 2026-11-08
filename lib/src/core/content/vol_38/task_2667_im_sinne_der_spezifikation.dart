// Sovereign Regulatory Normative Core - Task 2667
class Task2667Engine {
  static const int taskId = 2667;
  static const String identifier = 'im_sinne_der_spezifikation';
  static const String normativePhrase = 'im Sinne der Spezifikation';
  static const String arabicMeaning = 'وفق المفهوم الاصطلاحي المحدد بالمواصفة';
  static const String cefrLevel = 'B2';
  static const String regulatoryCategory = 'Begriffsdefinition';
  static const String audioAssetPath = 'assets/audio/regulatory/task_2667_im_sinne_der_spezifikation.ogg';
  static const String exampleGerman = 'Ein Block gilt im Sinne der Spezifikation als final bestätigt.';
  static const String exampleArabic = 'تُعد الكتلة بمفهوم المواصفة مؤكدة نهائياً بعد التوقيع.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': normativePhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': regulatoryCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => normativePhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
