/// Case required by prepositional governance.
enum RectionCase { akkusativ, dativ }

/// Governing specification for a verb with fixed preposition.
class VerbRectionSpec {
  final String verb;
  final String preposition;
  final RectionCase requiredCase;
  final String pronominalAdverb;

  const VerbRectionSpec({
    required this.verb,
    required this.preposition,
    required this.requiredCase,
    required this.pronominalAdverb,
  });
}

/// Analysis descriptor of coordinated verbs and conflict resolution.
class ValenceCoordinationResolution {
  final String firstVerb;
  final String secondVerb;
  final bool hasRectionCollision;
  final String problematicInput;
  final String grammaticallyDecoupledSentence;
  final String ruleExplanation;
  final String arabicCorrectionNote;

  ValenceCoordinationResolution({
    required this.firstVerb,
    required this.secondVerb,
    required this.hasRectionCollision,
    required this.problematicInput,
    required this.grammaticallyDecoupledSentence,
    required this.ruleExplanation,
    required this.arabicCorrectionNote,
  });

  Map<String, dynamic> toJson() => {
        'verb_1': firstVerb,
        'verb_2': secondVerb,
        'collision': hasRectionCollision,
        'faulty_input': problematicInput,
        'resolved': grammaticallyDecoupledSentence,
        'explanation': ruleExplanation,
        'arabic': arabicCorrectionNote,
      };
}

/// Offline rule engine identifying and resolving prepositional valence collisions (Rektionskonflikte)
/// when two coordinated verbs attempt to govern a single shared object illegally.
/// Automatically decouples the coordination using a proper pronominal adverb (Pronominaladverb).
class GermanValenceConflictResolverEngine {
  static const Map<String, VerbRectionSpec> _rectionRegistry = {
    'interessieren': VerbRectionSpec(
      verb: 'interessieren',
      preposition: 'für',
      requiredCase: RectionCase.akkusativ,
      pronominalAdverb: 'dafür',
    ),
    'teilnehmen': VerbRectionSpec(
      verb: 'teilnehmen',
      preposition: 'an',
      requiredCase: RectionCase.dativ,
      pronominalAdverb: 'daran',
    ),
    'beschaeftigen': VerbRectionSpec(
      verb: 'beschäftigen',
      preposition: 'mit',
      requiredCase: RectionCase.dativ,
      pronominalAdverb: 'damit',
    ),
    'achten': VerbRectionSpec(
      verb: 'achten',
      preposition: 'auf',
      requiredCase: RectionCase.akkusativ,
      pronominalAdverb: 'darauf',
    ),
    'beitragen': VerbRectionSpec(
      verb: 'beitragen',
      preposition: 'zu',
      requiredCase: RectionCase.dativ,
      pronominalAdverb: 'dazu',
    ),
    'warten': VerbRectionSpec(
      verb: 'warten',
      preposition: 'auf',
      requiredCase: RectionCase.akkusativ,
      pronominalAdverb: 'darauf',
    ),
    'zweifeln': VerbRectionSpec(
      verb: 'zweifeln',
      preposition: 'an',
      requiredCase: RectionCase.dativ,
      pronominalAdverb: 'daran',
    ),
  };

  /// Audit two coordinated verbs sharing an object and resolve any valence collision.
  static ValenceCoordinationResolution resolveCoordination({
    required String subject,
    required String verb1,
    required String verb2,
    required String targetNounPhrase, // e.g. "das Projekt", "die Regeln"
    String? verb1ReflexivePronoun,   // e.g. "sich"
    String? verb2ReflexivePronoun,
  }) {
    final v1Key = verb1.trim().toLowerCase().replaceAll('ä', 'ae').replaceAll('ö', 'oe').replaceAll('ü', 'ue');
    final v2Key = verb2.trim().toLowerCase().replaceAll('ä', 'ae').replaceAll('ö', 'oe').replaceAll('ü', 'ue');

    final spec1 = _rectionRegistry[v1Key];
    final spec2 = _rectionRegistry[v2Key];

    if (spec1 == null || spec2 == null) {
      // Unknown or standard verbs
      final sentence = '$subject $verb1 und $verb2 $targetNounPhrase.';
      return ValenceCoordinationResolution(
        firstVerb: verb1,
        secondVerb: verb2,
        hasRectionCollision: false,
        problematicInput: sentence,
        grammaticallyDecoupledSentence: sentence,
        ruleExplanation: 'Keine bekannte Rektionskollision festgestellt.',
        arabicCorrectionNote: 'تركيب قياسي دون تصادم في التعدية.',
      );
    }

    // Check collision: different prepositions OR different cases
    final hasCollision = (spec1.preposition != spec2.preposition) || (spec1.requiredCase != spec2.requiredCase);

    if (hasCollision) {
      // Resolve: Verb 1 takes full prepositional object, Verb 2 takes Pronominaladverb
      final refl1 = verb1ReflexivePronoun != null ? ' $verb1ReflexivePronoun' : '';
      final refl2 = verb2ReflexivePronoun != null ? ' $verb2ReflexivePronoun' : '';

      final clause1 = '$subject $verb1$refl1 ${spec1.preposition} $targetNounPhrase';
      final clause2 = 'nimmt$refl2 ${spec2.pronominalAdverb} teil'; // conjugated stem

      final resolved = '$subject $verb1$refl1 ${spec1.preposition} $targetNounPhrase und $verb2$refl2 ${spec2.pronominalAdverb}.'
          .replaceAll(RegExp(r'\s+'), ' ');

      final faulty = '$subject $verb1$refl1 und $verb2$refl2 ${spec2.preposition} $targetNounPhrase.';

      return ValenceCoordinationResolution(
        firstVerb: verb1,
        secondVerb: verb2,
        hasRectionCollision: true,
        problematicInput: faulty,
        grammaticallyDecoupledSentence: resolved,
        ruleExplanation: 'Rektionskollision: "${spec1.verb}" verlangt "${spec1.preposition} + ${spec1.requiredCase.name}", während "${spec2.verb}" "${spec2.preposition} + ${spec2.requiredCase.name}" regiert. Ein gemeinsames Objekt ist syntaktisch unzulässig.',
        arabicCorrectionNote: 'تصادم في التعدية الإعرابية: يطلب الفعل الأول حرف جر وحالة مختلفة عن الفعل الثاني. تم فك الارتباط بإعطاء الفعل الأول شبه الجملة الأصلية وتعويض الفعل الثاني بظرف ضميري مطابق (Pronominaladverb).',
      );
    }

    final resolved = '$subject $verb1 und $verb2 ${spec1.preposition} $targetNounPhrase.';
    return ValenceCoordinationResolution(
      firstVerb: verb1,
      secondVerb: verb2,
      hasRectionCollision: false,
      problematicInput: resolved,
      grammaticallyDecoupledSentence: resolved,
      ruleExplanation: 'Kompatible Rektion: Beide Verben regieren dieselbe Präposition und denselben Kasus.',
      arabicCorrectionNote: 'توافق كامل في التعدية: يشترك الفعلان في نفس حرف الجر والحالة الإعرابية.',
    );
  }
}
