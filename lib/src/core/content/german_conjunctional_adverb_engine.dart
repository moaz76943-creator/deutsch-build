/// Semantic category of the conjunctional adverb.
enum ConjunctionalAdverbCategory {
  consecutive,  // folglich, demnach, infolgedessen, somit
  concessive,   // trotzdem, gleichwohl, dennoch
  adversative,  // stattdessen, vielmehr, hingegen
  causalSpecial,// nämlich (nur im Mittelfeld!)
  conditional,  // andernfalls, sonst
}

/// Syntactic positioning of the adverb.
enum AdverbPlacementSlot { positionOneVorfeld, middleFieldSlot }

/// Analysis descriptor of an engineered conjunctional adverb sentence.
class ConjunctionalAdverbSentenceStructure {
  final String adverb;
  final ConjunctionalAdverbCategory category;
  final AdverbPlacementSlot slot;
  final String generatedSentence;
  final bool adheresToInversion;
  final String punctuationRuleNote;
  final String arabicExplanation;

  ConjunctionalAdverbSentenceStructure({
    required this.adverb,
    required this.category,
    required this.slot,
    required this.generatedSentence,
    required this.adheresToInversion,
    required this.punctuationRuleNote,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'adverb': adverb,
        'category': category.name,
        'slot': slot.name,
        'sentence': generatedSentence,
        'inversion': adheresToInversion,
        'rule': punctuationRuleNote,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine constructing and validating German Conjunctional Adverbs (Konjunktionaladverbien).
/// Enforces mandatory verb-second inversion when placed in Position 1, forbids comma separation after adverbs,
/// and enforces the strict constraint that "nämlich" can never occupy Position 1.
class GermanConjunctionalAdverbEngine {
  static const Map<String, ConjunctionalAdverbCategory> _adverbRegistry = {
    'folglich': ConjunctionalAdverbCategory.consecutive,
    'demnach': ConjunctionalAdverbCategory.consecutive,
    'infolgedessen': ConjunctionalAdverbCategory.consecutive,
    'somit': ConjunctionalAdverbCategory.consecutive,
    'trotzdem': ConjunctionalAdverbCategory.concessive,
    'dennoch': ConjunctionalAdverbCategory.concessive,
    'gleichwohl': ConjunctionalAdverbCategory.concessive,
    'stattdessen': ConjunctionalAdverbCategory.adversative,
    'vielmehr': ConjunctionalAdverbCategory.adversative,
    'hingegen': ConjunctionalAdverbCategory.adversative,
    'andernfalls': ConjunctionalAdverbCategory.conditional,
    'sonst': ConjunctionalAdverbCategory.conditional,
    'nämlich': ConjunctionalAdverbCategory.causalSpecial,
    'naemlich': ConjunctionalAdverbCategory.causalSpecial,
  };

  /// Build grammatically sound sentence incorporating a conjunctional adverb.
  static ConjunctionalAdverbSentenceStructure constructSentence({
    required String adverb,
    required String subject,
    required String finiteVerb,
    required String remainder,
    AdverbPlacementSlot slot = AdverbPlacementSlot.positionOneVorfeld,
    String precedingSentence = '',
  }) {
    final cleanAdv = adverb.trim().toLowerCase();
    final category = _adverbRegistry[cleanAdv] ?? ConjunctionalAdverbCategory.consecutive;

    // Critical Constraint: "nämlich" can never be placed at Position 1 (Vorfeld)
    if ((cleanAdv == 'nämlich' || cleanAdv == 'naemlich') && slot == AdverbPlacementSlot.positionOneVorfeld) {
      throw ArgumentError(
        'Grammatikfehler: "nämlich" darf niemals auf Position 1 im Vorfeld stehen! Es gehört immer ins Mittelfeld.',
      );
    }

    String sentence = '';
    String rule = '';
    String arabic = '';

    if (slot == AdverbPlacementSlot.positionOneVorfeld) {
      // Position 1: Adverb + Verb + Subject + Remainder (Inversion!)
      // Note: In German, NO comma is placed after the conjunctional adverb (unlike English "Consequently, ...")
      final capAdv = cleanAdv[0].toUpperCase() + cleanAdv.substring(1);
      final subClean = subject.trim();
      final remStr = remainder.trim().isNotEmpty ? ' ${remainder.trim()}' : '';
      sentence = '$capAdv $finiteVerb $subClean$remStr.';
      rule = 'يحتل الظرف الرابط الموقع الأول (Position 1)، مما يفرض تقديم الفعل مباشرة على الفاعل (Inversion) دون وضع فاصلة بعد الظرف.';
    } else {
      // Mittelfeld: Subject + Verb + Adverb + Remainder
      final subClean = subject.trim();
      final remStr = remainder.trim().isNotEmpty ? ' ${remainder.trim()}' : '';
      sentence = '$subClean $finiteVerb $cleanAdv$remStr.';
      rule = 'يستقر الظرف في الحيز الأوسط (Mittelfeld) بعد الفعل المصرف مباشرة دون تغيير ترتيب الجملة.';
    }

    if (precedingSentence.trim().isNotEmpty) {
      sentence = '${precedingSentence.trim()} $sentence';
    }

    switch (category) {
      case ConjunctionalAdverbCategory.consecutive:
        arabic = 'ظرف رابط يفيد النتيجة المنطقية المترتبة (وبناءً على ذلك / بالتالي)';
        break;
      case ConjunctionalAdverbCategory.concessive:
        arabic = 'ظرف رابط يفيد الاستدراك وتجاوز العقبة (مع ذلك / بالرغم من ذلك)';
        break;
      case ConjunctionalAdverbCategory.adversative:
        arabic = 'ظرف رابط يفيد المقابلة والتعاكس (بدلاً من ذلك / بل بالأحرى)';
        break;
      case ConjunctionalAdverbCategory.conditional:
        arabic = 'ظرف رابط يفيد التحذير والشرط المعاكس (وإلا / في غير هذه الحالة)';
        break;
      case ConjunctionalAdverbCategory.causalSpecial:
        arabic = 'ظرف رابط تفسيري يفيد التعليل (إذ إنه / ذلك أنه) ومكانه الحصري في وسط الجملة';
        break;
    }

    return ConjunctionalAdverbSentenceStructure(
      adverb: cleanAdv,
      category: category,
      slot: slot,
      generatedSentence: sentence,
      adheresToInversion: (slot == AdverbPlacementSlot.positionOneVorfeld),
      punctuationRuleNote: rule,
      arabicExplanation: arabic,
    );
  }
}
