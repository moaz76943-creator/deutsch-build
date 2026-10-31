enum PerfectAuxiliary { haben, sein }

class IrregularVerbEntry {
  final String infinitiv;
  final String praeteritum;
  final String partizip2;
  final PerfectAuxiliary auxiliary;
  final String? present3rdPerson; // للتغيير الصوتي بالحاضر مثل: fährt, spricht, liest
  final String arabicMeaning;

  const IrregularVerbEntry({
    required this.infinitiv,
    required this.praeteritum,
    required this.partizip2,
    required this.auxiliary,
    this.present3rdPerson,
    required this.arabicMeaning,
  });
}

/// Offline engine mapping German strong/irregular verb principal parts and auxiliary selection.
class IrregularVerbEngine {
  static const Map<String, IrregularVerbEntry> _verbs = {
    // 1. سلسلة i - a - u / e - a - o
    'trinken': IrregularVerbEntry(
      infinitiv: 'trinken',
      praeteritum: 'trank',
      partizip2: 'getrunken',
      auxiliary: PerfectAuxiliary.haben,
      arabicMeaning: 'يشرب',
    ),
    'sprechen': IrregularVerbEntry(
      infinitiv: 'sprechen',
      praeteritum: 'sprach',
      partizip2: 'gesprochen',
      auxiliary: PerfectAuxiliary.haben,
      present3rdPerson: 'spricht', // e -> i
      arabicMeaning: 'يتحدث',
    ),
    'sehen': IrregularVerbEntry(
      infinitiv: 'sehen',
      praeteritum: 'sah',
      partizip2: 'gesehen',
      auxiliary: PerfectAuxiliary.haben,
      present3rdPerson: 'sieht', // e -> ie
      arabicMeaning: 'يرى',
    ),

    // 2. أفعال الحركة مع sein: a - u - a / ie - o - o
    'fahren': IrregularVerbEntry(
      infinitiv: 'fahren',
      praeteritum: 'fuhr',
      partizip2: 'gefahren',
      auxiliary: PerfectAuxiliary.sein,
      present3rdPerson: 'fährt', // a -> ä
      arabicMeaning: 'يسافر / يقود',
    ),
    'gehen': IrregularVerbEntry(
      infinitiv: 'gehen',
      praeteritum: 'ging',
      partizip2: 'gegangen',
      auxiliary: PerfectAuxiliary.sein,
      arabicMeaning: 'يمشي / يذهب',
    ),
    'bleiben': IrregularVerbEntry(
      infinitiv: 'bleiben',
      praeteritum: 'blieb',
      partizip2: 'geblieben',
      auxiliary: PerfectAuxiliary.sein,
      arabicMeaning: 'يبقى',
    ),

    // 3. أفعال الحالة وتغير الحالة
    'einschlafen': IrregularVerbEntry(
      infinitiv: 'einschlafen',
      praeteritum: 'schlief ein',
      partizip2: 'eingeschlafen',
      auxiliary: PerfectAuxiliary.sein,
      present3rdPerson: 'schläft ein',
      arabicMeaning: 'يستغرق في النوم',
    ),
  };

  IrregularVerbEntry? lookup(String verb) => _verbs[verb.toLowerCase().trim()];

  /// صياغة زمن الماضي التام (Perfekt) كاملاً
  String formPerfekt(String verb, String subject, {bool isPlural = false}) {
    final entry = lookup(verb);
    if (entry == null) return '$subject hat ge$verb' 't'; // افتراضي قياسي

    final auxVerb = entry.auxiliary == PerfectAuxiliary.sein
        ? (isPlural ? 'sind' : 'ist')
        : (isPlural ? 'haben' : 'hat');

    return '$subject $auxVerb ${entry.partizip2}';
  }
}
