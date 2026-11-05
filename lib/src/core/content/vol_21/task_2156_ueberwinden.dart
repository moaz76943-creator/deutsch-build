// Sovereign Linguistic Core - Task 2156
class Task2156Engine {
  static const int taskId = 2156;
  static const String verb = 'ueberwinden';
  static const String praeteritum = 'ueberwand';
  static const String perfekt = 'hat ueberwunden';
  static const String arabic = 'يتغلب على عقبة';
  static const String ipa = '[yːbɐˈvɪndn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefr = 'C1';
  static const String audioAsset = 'assets/audio/de/task_2156_ueberwinden.ogg';
  static const String exampleDe = 'Sie ueberwand alle Huerden.';
  static const String exampleAr = 'تغلبت على جميع العقبات المهنية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verb, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabic, 'ipa': ipa, 'case': valencyCase,
    'cefr': cefr, 'audio': audioAsset, 'ex_de': exampleDe, 'ex_ar': exampleAr,
  };

  static bool validate() => verb.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
