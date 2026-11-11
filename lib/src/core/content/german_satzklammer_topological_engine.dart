/// Type of grammatical object in the Mittelfeld.
enum ObjectRealizationType { nounObject, pronounObject }

/// Analysis descriptor of the Mittelfeld sequence.
class MittelfeldSequenceStructure {
  final String subject;
  final String finiteVerb;
  final String dativeElement;
  final ObjectRealizationType dativeType;
  final String accusativeElement;
  final ObjectRealizationType accusativeType;
  final String orderedMittelfeld;
  final String fullSentence;
  final String appliedRuleExplanation;
  final String arabicRuleSummary;

  MittelfeldSequenceStructure({
    required this.subject,
    required this.finiteVerb,
    required this.dativeElement,
    required this.dativeType,
    required this.accusativeElement,
    required this.accusativeType,
    required this.orderedMittelfeld,
    required this.fullSentence,
    required this.appliedRuleExplanation,
    required this.arabicRuleSummary,
  });

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'verb': finiteVerb,
        'dative': dativeElement,
        'accusative': accusativeElement,
        'mittelfeld': orderedMittelfeld,
        'sentence': fullSentence,
        'rule': appliedRuleExplanation,
        'arabic': arabicRuleSummary,
      };
}

/// Offline rule engine enforcing German Topological Field (Satzklammer) rules
/// and strict Mittelfeld word ordering:
/// 1. Pronoun before Noun: Pronouns strictly precede nominal objects.
/// 2. Double Pronouns: Accusative pronoun MUST precede Dative pronoun (es ihm).
/// 3. Double Nouns: Dative noun precedes Accusative noun (dem Mann das Buch).
class GermanSatzklammerTopologicalEngine {
  /// Order dative and accusative objects in the Mittelfeld according to strict German topology.
  static MittelfeldSequenceStructure orderMittelfeldObjects({
    required String subject,
    required String finiteVerb,
    required String dativeObject,
    required ObjectRealizationType dativeType,
    required String accusativeObject,
    required ObjectRealizationType accusativeType,
    String finalCluster = '', // Partizip II, Infinitiv, or separable prefix
  }) {
    String orderedObjects = '';
    String rule = '';
    String arabic = '';

    if (dativeType == ObjectRealizationType.pronounObject &&
        accusativeType == ObjectRealizationType.pronounObject) {
      // Rule 1: Two pronouns -> Accusative MUST precede Dative (es ihm / es ihr / es ihnen)
      orderedObjects = '${accusativeObject.trim()} ${dativeObject.trim()}';
      rule = 'Regel der zwei Pronomen: Treffen zwei Pronomen im Mittelfeld aufeinander, steht das Akkusativpronomen IMMER vor dem Dativpronomen (es ihm).';
      arabic = 'قاعدة الضميرين: إذا كان المفعولان ضميرين، يتقدم المنصوب (Akkusativ) وجوباً على المجرور (Dativ): [es ihm] وليس العكس.';
    } else if (dativeType == ObjectRealizationType.nounObject &&
        accusativeType == ObjectRealizationType.pronounObject) {
      // Rule 2: Pronoun before Noun -> Accusative pronoun precedes Dative noun
      orderedObjects = '${accusativeObject.trim()} ${dativeObject.trim()}';
      rule = 'Pronomen-vor-Nomen-Regel: Das Akkusativpronomen steht vor dem nominalen Dativobjekt.';
      arabic = 'قاعدة تقدم الضمير على الاسم: الضمير المنصوب يسبق الاسم المجرور وجوباً.';
    } else if (dativeType == ObjectRealizationType.pronounObject &&
        accusativeType == ObjectRealizationType.nounObject) {
      // Rule 3: Pronoun before Noun -> Dative pronoun precedes Accusative noun
      orderedObjects = '${dativeObject.trim()} ${accusativeObject.trim()}';
      rule = 'Pronomen-vor-Nomen-Regel: Das Dativpronomen steht vor dem nominalen Akkusativobjekt.';
      arabic = 'قاعدة تقدم الضمير على الاسم: الضمير المجرور يسبق الاسم المنصوب وجوباً.';
    } else {
      // Rule 4: Two nouns -> Dative noun precedes Accusative noun
      orderedObjects = '${dativeObject.trim()} ${accusativeObject.trim()}';
      rule = 'Nomen-Reihenfolge: Bei zwei Nomen steht das Dativobjekt vor dem Akkusativobjekt (dem Mann das Buch).';
      arabic = 'قاعدة الاسمين الصريحين: يتقدم المجرور بالداتيف على المنصوب بالأكوزاتيف: [dem Mann das Buch].';
    }

    final endStr = finalCluster.trim().isNotEmpty ? ' ${finalCluster.trim()}' : '';
    final sentence = '${subject.trim()} ${finiteVerb.trim()} $orderedObjects$endStr.'
        .replaceAll(RegExp(r'\s+'), ' ');

    return MittelfeldSequenceStructure(
      subject: subject.trim(),
      finiteVerb: finiteVerb.trim(),
      dativeElement: dativeObject.trim(),
      dativeType: dativeType,
      accusativeElement: accusativeObject.trim(),
      accusativeType: accusativeType,
      orderedMittelfeld: orderedObjects,
      fullSentence: sentence,
      appliedRuleExplanation: rule,
      arabicRuleSummary: arabic,
    );
  }
}
