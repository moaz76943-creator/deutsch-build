/// Type of cohesive reference mechanism in text.
enum CohesiveReferenceType {
  nearDemonstrative,     // dieser (القريب المذكور أخيراً)
  distalDemonstrative,   // jener (البعيد المذكور أولاً)
  determinativeRelative, // derjenige (الذي يتبعه اسم موصول)
  numericalIdentity,     // derselbe (عين الشيء بذاته)
  qualitativeIdentity,   // der gleiche (نظير الشيء ومثيله)
  exemplaryType,         // solcher (مثل هذا النوع)
}

/// Grammar gender and number.
enum CohesionGender { masculine, feminine, neuter, plural }

/// Grammatical case of the anaphoric pronoun.
enum CohesionCase { nominative, accusative, dative, genitive }

/// Structure representing an inflected anaphoric cohesive element.
class CohesiveAnaphoricElement {
  final CohesiveReferenceType referenceType;
  final CohesionGender gender;
  final CohesionCase gramCase;
  final String inflectedPronoun;
  final String antecedentNoun;
  final String sampleSentence;
  final String arabicSemanticDistinction;

  CohesiveAnaphoricElement({
    required this.referenceType,
    required this.gender,
    required this.gramCase,
    required this.inflectedPronoun,
    required this.antecedentNoun,
    required this.sampleSentence,
    required this.arabicSemanticDistinction,
  });

  Map<String, dynamic> toJson() => {
        'type': referenceType.name,
        'gender': gender.name,
        'case': gramCase.name,
        'pronoun': inflectedPronoun,
        'antecedent': antecedentNoun,
        'sentence': sampleSentence,
        'arabic': arabicSemanticDistinction,
      };
}

/// Offline rule engine constructing and verifying German textual cohesion (Textkohäsion).
/// Implements precise anaphoric distinctions, notably between "derselbe" (identical token)
/// and "der gleiche" (identical type/look).
class GermanTextCohesionEngine {
  /// Build anaphoric cohesive reference.
  static CohesiveAnaphoricElement buildAnaphoricReference({
    required CohesiveReferenceType type,
    required CohesionGender gender,
    required CohesionCase gramCase,
    required String antecedent,
  }) {
    String pronoun = '';
    String sample = '';
    String arabic = '';

    switch (type) {
      case CohesiveReferenceType.numericalIdentity:
        // derselbe / dieselbe / dasselbe
        if (gender == CohesionGender.masculine) {
          pronoun = (gramCase == CohesionCase.accusative) ? 'denselben' : ((gramCase == CohesionCase.dative) ? 'demselben' : 'derselbe');
        } else if (gender == CohesionGender.feminine) {
          pronoun = (gramCase == CohesionCase.dative || gramCase == CohesionCase.genitive) ? 'derselben' : 'dieselbe';
        } else if (gender == CohesionGender.neuter) {
          pronoun = (gramCase == CohesionCase.dative) ? 'demselben' : 'dasselbe';
        } else {
          pronoun = (gramCase == CohesionCase.dative) ? 'denselben' : 'dieselben';
        }
        sample = 'Wir wohnen im selben Haus und benutzen $pronoun $antecedent.';
        arabic = 'تطابق عيني كامل (عين الشيء بذاته وشخصه، لا شبيهه)';
        break;

      case CohesiveReferenceType.qualitativeIdentity:
        // der gleiche / die gleiche / das gleiche
        if (gender == CohesionGender.masculine) {
          pronoun = (gramCase == CohesionCase.accusative) ? 'den gleichen' : ((gramCase == CohesionCase.dative) ? 'dem gleichen' : 'der gleiche');
        } else if (gender == CohesionGender.feminine) {
          pronoun = (gramCase == CohesionCase.dative) ? 'der gleichen' : 'die gleiche';
        } else if (gender == CohesionGender.neuter) {
          pronoun = (gramCase == CohesionCase.dative) ? 'dem gleichen' : 'das gleiche';
        } else {
          pronoun = (gramCase == CohesionCase.dative) ? 'den gleichen' : 'die gleichen';
        }
        sample = 'Ich habe mir $pronoun $antecedent gekauft wie du.';
        arabic = 'تطابق نوعي ومثلي (نظير الشيء ومثيله في النوع والشكل، وليس ذاته)';
        break;

      case CohesiveReferenceType.nearDemonstrative:
        // dieser / diese / dieses
        if (gender == CohesionGender.masculine) {
          pronoun = (gramCase == CohesionCase.accusative) ? 'diesen' : ((gramCase == CohesionCase.dative) ? 'diesem' : 'dieser');
        } else if (gender == CohesionGender.feminine) {
          pronoun = (gramCase == CohesionCase.dative) ? 'dieser' : 'diese';
        } else if (gender == CohesionGender.neuter) {
          pronoun = (gramCase == CohesionCase.dative) ? 'diesem' : 'dieses';
        } else {
          pronoun = (gramCase == CohesionCase.dative) ? 'diesen' : 'diese';
        }
        sample = '$pronoun $antecedent ist von entscheidender Bedeutung.';
        arabic = 'اسم إشارة إحالي للقريب (المذكور أخيراً في النص)';
        break;

      case CohesiveReferenceType.distalDemonstrative:
        // jener / jene / jenes
        if (gender == CohesionGender.masculine) {
          pronoun = (gramCase == CohesionCase.accusative) ? 'jenen' : 'jener';
        } else if (gender == CohesionGender.feminine) {
          pronoun = 'jene';
        } else if (gender == CohesionGender.neuter) {
          pronoun = 'jenes';
        } else {
          pronoun = 'jene';
        }
        sample = 'Im Gegensatz zu diesem ist $pronoun $antecedent bereits abgeschlossen.';
        arabic = 'اسم إشارة إحالي للبعيد (المذكور أولاً لفض الالتباس)';
        break;

      case CohesiveReferenceType.determinativeRelative:
        // derjenige, der ...
        if (gender == CohesionGender.masculine) {
          pronoun = (gramCase == CohesionCase.accusative) ? 'denjenigen' : 'derjenige';
        } else if (gender == CohesionGender.feminine) {
          pronoun = 'diejenige';
        } else if (gender == CohesionGender.neuter) {
          pronoun = 'dasjenige';
        } else {
          pronoun = 'diejenigen';
        }
        sample = '$pronoun $antecedent, der fleißig lernt, hat Erfolg.';
        arabic = 'ضمير دال موصول يحدد الشخص أو الشيء المشار إليه بالجملة الموصولة';
        break;

      case CohesiveReferenceType.exemplaryType:
        // solcher / solche / solches
        if (gender == CohesionGender.masculine) {
          pronoun = (gramCase == CohesionCase.accusative) ? 'solchen' : 'solcher';
        } else if (gender == CohesionGender.feminine) {
          pronoun = 'solche';
        } else if (gender == CohesionGender.neuter) {
          pronoun = 'solches';
        } else {
          pronoun = 'solche';
        }
        sample = 'Für $pronoun $antecedent gibt es klare Regeln.';
        arabic = 'اسم دال على النوع والمثال (مثل هذا النوع)';
        break;
    }

    return CohesiveAnaphoricElement(
      referenceType: type,
      gender: gender,
      gramCase: gramCase,
      inflectedPronoun: pronoun,
      antecedentNoun: antecedent,
      sampleSentence: sample,
      arabicSemanticDistinction: arabic,
    );
  }
}
