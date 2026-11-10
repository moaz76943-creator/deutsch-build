/// Grammatical person for verb conjugation.
enum GrammaticalPerson { ich, du, erSieEs, wir, ihr, sieSie }

/// Conjugated Konjunktiv II form descriptor.
class KonjunktivTwoForm {
  final String baseVerb;
  final GrammaticalPerson person;
  final String syntheticForm; // e.g. "wäre", "hätte", "könnte"
  final String analyticForm;  // e.g. "würde ... sein / haben / können"
  final String politeSample;

  KonjunktivTwoForm({
    required this.baseVerb,
    required this.person,
    required this.syntheticForm,
    required this.analyticForm,
    required this.politeSample,
  });

  Map<String, dynamic> toJson() => {
        'verb': baseVerb,
        'person': person.name,
        'synthetic': syntheticForm,
        'analytic': analyticForm,
        'sample': politeSample,
      };
}

/// Offline linguistic rule engine for German Konjunktiv II (Subjunctive II).
/// Generates synthetic irregular roots (sein -> wäre, haben -> hätte, modal verbs -> könnte/müsste)
/// and analytic "würde + Infinitiv" structures for standard verbs.
class GermanKonjunktivTwoEngine {
  static const Map<String, Map<GrammaticalPerson, String>> _syntheticRoots = {
    'sein': {
      GrammaticalPerson.ich: 'wäre',
      GrammaticalPerson.du: 'wärest',
      GrammaticalPerson.erSieEs: 'wäre',
      GrammaticalPerson.wir: 'wären',
      GrammaticalPerson.ihr: 'wäret',
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
    'koennen': {
      GrammaticalPerson.ich: 'könnte',
      GrammaticalPerson.du: 'könntest',
      GrammaticalPerson.erSieEs: 'könnte',
      GrammaticalPerson.wir: 'könnten',
      GrammaticalPerson.ihr: 'könntet',
      GrammaticalPerson.sieSie: 'könnten',
    },
    'duerfen': {
      GrammaticalPerson.ich: 'dürfte',
      GrammaticalPerson.du: 'dürftest',
      GrammaticalPerson.erSieEs: 'dürfte',
      GrammaticalPerson.wir: 'dürften',
      GrammaticalPerson.ihr: 'dürftet',
      GrammaticalPerson.sieSie: 'dürften',
    },
  };

  static const Map<GrammaticalPerson, String> _wuerdeAuxiliary = {
    GrammaticalPerson.ich: 'würde',
    GrammaticalPerson.du: 'würdest',
    GrammaticalPerson.erSieEs: 'würde',
    GrammaticalPerson.wir: 'würden',
    GrammaticalPerson.ihr: 'würdet',
    GrammaticalPerson.sieSie: 'würden',
  };

  /// Build Konjunktiv II form for a given verb and person.
  static KonjunktivTwoForm buildForm({
    required String verb,
    required GrammaticalPerson person,
    String? complement,
  }) {
    final cleanVerb = verb.trim().toLowerCase()
        .replaceAll('ö', 'oe')
        .replaceAll('ä', 'ae')
        .replaceAll('ü', 'ue');

    final aux = _wuerdeAuxiliary[person]!;
    final analytic = '$aux ${complement != null ? '$complement ' : ''}$verb';

    String synthetic = analytic;
    if (_syntheticRoots.containsKey(cleanVerb)) {
      synthetic = _syntheticRoots[cleanVerb]![person]!;
    }

    // Polite sample generator
    String sample = '';
    if (cleanVerb == 'koennen') {
      sample = '${_syntheticRoots['koennen']![person]!} Sie mir bitte helfen?';
    } else if (cleanVerb == 'haben') {
      sample = '${_syntheticRoots['haben']![person]!} Sie einen Moment Zeit?';
    } else {
      sample = '$aux Sie bitte das Fenster schließen?';
    }

    return KonjunktivTwoForm(
      baseVerb: verb,
      person: person,
      syntheticForm: synthetic,
      analyticForm: analytic,
      politeSample: sample,
    );
  }
}
