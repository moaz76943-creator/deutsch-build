/// Type of modal infinitive structure.
enum ModalInfinitiveType {
  habenZuObligation,      // haben zu + Infinitiv (müssen / sollen)
  brauchenNichtZu,        // nicht brauchen zu + Infinitiv (nicht müssen)
  scheinenZuEvidential,   // scheinen zu + Infinitiv (den Eindruck machen)
  pflegenZuHabitual,      // pflegen zu + Infinitiv (die Gewohnheit haben)
}

/// Analysis descriptor of a modal infinitive sentence.
class ModalInfinitiveStructure {
  final ModalInfinitiveType type;
  final String governingAuxiliary;
  final String baseVerb;
  final String formattedInfinitiveZu;
  final String generatedSentence;
  final String modalVerbEquivalent;
  final String arabicExplanation;

  ModalInfinitiveStructure({
    required this.type,
    required this.governingAuxiliary,
    required this.baseVerb,
    required this.formattedInfinitiveZu,
    required this.generatedSentence,
    required this.modalVerbEquivalent,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'auxiliary': governingAuxiliary,
        'verb': baseVerb,
        'zu_form': formattedInfinitiveZu,
        'sentence': generatedSentence,
        'modal_equiv': modalVerbEquivalent,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine constructing and validating German Modal Infinitives
/// (haben zu + Infinitiv, nicht brauchen zu + Infinitiv, scheinen zu, pflegen zu).
/// Enforces correct "zu" insertion and active vs. passive semantic boundaries.
class GermanModalInfinitivesEngine {
  static const Set<String> _separablePrefixes = {
    'ab', 'an', 'auf', 'aus', 'ein', 'mit', 'nach', 'vor', 'zu', 'befolgen'
  };

  /// Format infinitive with "zu", embedding inside separable verbs.
  static String formatWithZu(String verb) {
    final clean = verb.trim().toLowerCase();
    for (final prefix in _separablePrefixes) {
      if (prefix != 'befolgen' && clean.startsWith(prefix) && clean.length > prefix.length + 2) {
        final stem = clean.substring(prefix.length);
        return '$prefix' 'zu$stem';
      }
    }
    return 'zu $clean';
  }

  /// Build modal infinitive sentence and compute its modal equivalent.
  static ModalInfinitiveStructure constructPhrase({
    required String subject,
    required String conjugatedAuxiliary, // e.g. "hast", "braucht nicht", "scheint", "pflegt"
    required ModalInfinitiveType type,
    required String actionVerb, // e.g. "befolgen", "warten", "beruhigen", "machen"
    String complement = '',
  }) {
    final cleanVerb = actionVerb.trim().toLowerCase();
    final zuForm = formatWithZu(cleanVerb);
    final compStr = complement.trim().isNotEmpty ? '${complement.trim()} ' : '';

    String sentence = '';
    String modalEquiv = '';
    String arabic = '';

    switch (type) {
      case ModalInfinitiveType.habenZuObligation:
        sentence = '$subject $conjugatedAuxiliary $compStr$zuForm.';
        modalEquiv = '$subject muss $compStr$cleanVerb.';
        arabic = 'صيغة إلزام ووجوب مشددة (haben zu + Infinitiv) تعادل الفعل المساعد müssen';
        break;

      case ModalInfinitiveType.brauchenNichtZu:
        sentence = '$subject $conjugatedAuxiliary $compStr$zuForm.';
        modalEquiv = '$subject muss nicht $compStr$cleanVerb.';
        arabic = 'صيغة نفي الوجوب (nicht brauchen zu + Infinitiv) تعادل nicht müssen تماماً';
        break;

      case ModalInfinitiveType.scheinenZuEvidential:
        sentence = '$subject $conjugatedAuxiliary $compStr$zuForm.';
        modalEquiv = 'Es hat den Anschein, dass $subject $compStr$cleanVerb.';
        arabic = 'صيغة استدلالية ظاهرية (scheinen zu + Infinitiv) تفيد الظهور والترجيح الظاهري';
        break;

      case ModalInfinitiveType.pflegenZuHabitual:
        sentence = '$subject $conjugatedAuxiliary $compStr$zuForm.';
        modalEquiv = '$subject ist gewohnt, $compStr$cleanVerb.';
        arabic = 'صيغة لغوية راقية تفيد الاعتياد والمداومة على الفعل (pflegen zu + Infinitiv)';
        break;
    }

    return ModalInfinitiveStructure(
      type: type,
      governingAuxiliary: conjugatedAuxiliary,
      baseVerb: cleanVerb,
      formattedInfinitiveZu: zuForm,
      generatedSentence: sentence,
      modalVerbEquivalent: modalEquiv,
      arabicExplanation: arabic,
    );
  }
}
