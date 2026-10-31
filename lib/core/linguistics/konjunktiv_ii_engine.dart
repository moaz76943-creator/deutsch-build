enum GrammaticalPerson { ich, du, erSieEs, wir, ihr, sieSie }
enum KonjunktivTense { present, past }

/// Offline linguistic engine generating and validating German Konjunktiv II constructions.
class KonjunktivIiEngine {
  // تصريف الأفعال الشاذة والمساعدة الأكثر شيوعاً في الحاضر
  static const Map<String, Map<GrammaticalPerson, String>> _syntheticRoots = {
    'sein': {
      GrammaticalPerson.ich: 'wäre',
      GrammaticalPerson.du: 'wärst',
      GrammaticalPerson.erSieEs: 'wäre',
      GrammaticalPerson.wir: 'wären',
      GrammaticalPerson.ihr: 'wärt',
      GrammaticalPerson.sieSie: 'wären',
    },
    'haben': {
      GrammaticalPerson.ich: 'hätte',
      GrammaticalPerson.du: 'hättest',
      GrammaticalPerson.erSieEs: 'hätte',
      GrammaticalPerson.wir: 'hätten',
      GrammaticalPerson.ihr: 'hättet',
      GrammaticalPerson.sieSie: 'hätten',
    },
    'werden': {
      GrammaticalPerson.ich: 'würde',
      GrammaticalPerson.du: 'würdest',
      GrammaticalPerson.erSieEs: 'würde',
      GrammaticalPerson.wir: 'würden',
      GrammaticalPerson.ihr: 'würdet',
      GrammaticalPerson.sieSie: 'würden',
    },
    'können': {
      GrammaticalPerson.ich: 'könnte',
      GrammaticalPerson.du: 'könntest',
      GrammaticalPerson.erSieEs: 'könnte',
      GrammaticalPerson.wir: 'könnten',
      GrammaticalPerson.ihr: 'könntet',
      GrammaticalPerson.sieSie: 'könnten',
    },
    'müssen': {
      GrammaticalPerson.ich: 'müsste',
      GrammaticalPerson.du: 'müsstest',
      GrammaticalPerson.erSieEs: 'müsste',
      GrammaticalPerson.wir: 'müssten',
      GrammaticalPerson.ihr: 'müsstet',
      GrammaticalPerson.sieSie: 'müssten',
    },
    'wissen': {
      GrammaticalPerson.ich: 'wüsste',
      GrammaticalPerson.du: 'wüsstest',
      GrammaticalPerson.erSieEs: 'wüsste',
      GrammaticalPerson.wir: 'wüssten',
      GrammaticalPerson.ihr: 'wüsstet',
      GrammaticalPerson.sieSie: 'wüssten',
    },
  };

  /// صياغة Konjunktiv II للحاضر (إما تركيبي للجذور الشائعة أو تحليلي عبر würde + Infinitiv)
  String conjugatePresent(String verb, GrammaticalPerson person) {
    final lowerVerb = verb.toLowerCase();
    if (_syntheticRoots.containsKey(lowerVerb)) {
      return _syntheticRoots[lowerVerb]![person]!;
    }
    // الصيغة التحليلية الافتراضية لبقية الأفعال: würde + مصدر
    final wuerdeForm = _syntheticRoots['werden']![person]!;
    return '$wuerdeForm $verb';
  }

  /// صياغة Konjunktiv II للماضي (wäre / hätte + Partizip II)
  String conjugatePast({
    required GrammaticalPerson person,
    required String auxiliary, // 'sein' or 'haben'
    required String partizipIi,
  }) {
    final auxForm = _syntheticRoots[auxiliary.toLowerCase()]?[person] ?? 'hätte';
    return '$auxForm $partizipIi';
  }

  /// صياغة طلب مهذب (Polite Request)
  String generatePoliteRequest(String actionInfinitiv, {GrammaticalPerson person = GrammaticalPerson.sieSie}) {
    final koennteForm = _syntheticRoots['können']![person]!;
    return '$koennteForm Sie bitte $actionInfinitiv?';
  }
}
