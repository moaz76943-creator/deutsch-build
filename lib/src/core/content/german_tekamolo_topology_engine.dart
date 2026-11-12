/// Adverbial semantic classification under TeKaMoLo canon.
enum AdverbialSlotType { temporal, causal, modal, local }

/// Constituent chosen to occupy the Vorfeld (Position 1).
enum VorfeldFocusChoice { subjectDefault, temporalFocus, causalFocus, modalFocus, localFocus }

/// Analysis descriptor of an engineered sentence with verified TeKaMoLo sequence.
class TeKaMoLoSequenceStructure {
  final VorfeldFocusChoice focusChoice;
  final String temporalComponent;
  final String causalComponent;
  final String modalComponent;
  final String localComponent;
  final String generatedSentence;
  final bool followsStrictCanonicalOrder;
  final String topologicalRuleExplanation;
  final String arabicRuleSummary;

  TeKaMoLoSequenceStructure({
    required this.focusChoice,
    required this.temporalComponent,
    required this.causalComponent,
    required this.modalComponent,
    required this.localComponent,
    required this.generatedSentence,
    required this.followsStrictCanonicalOrder,
    required this.topologicalRuleExplanation,
    required this.arabicRuleSummary,
  });

  Map<String, dynamic> toJson() => {
        'focus': focusChoice.name,
        'temporal': temporalComponent,
        'causal': causalComponent,
        'modal': modalComponent,
        'local': localComponent,
        'sentence': generatedSentence,
        'canonical': followsStrictCanonicalOrder,
        'rule': topologicalRuleExplanation,
        'arabic': arabicRuleSummary,
      };
}

/// Offline rule engine enforcing German Adverbial Topology (TeKaMoLo: Temporal -> Kausal -> Modal -> Lokal).
/// Accurately manages Vorfeld focus shifts with main-clause inversion and sequence integrity.
class GermanTeKaMoLoTopologyEngine {
  /// Build sentence aligning adverbial phrases into strict TeKaMoLo topology.
  static TeKaMoLoSequenceStructure assembleSentence({
    required String subject,
    required String finiteVerb,
    String temporal = '',
    String causal = '',
    String modal = '',
    String local = '',
    VorfeldFocusChoice focus = VorfeldFocusChoice.subjectDefault,
    String verbClusterEnd = '', // Partizip II, Infinitiv, or separable prefix
  }) {
    final sClean = subject.trim();
    final vClean = finiteVerb.trim();
    final tClean = temporal.trim();
    final kClean = causal.trim();
    final mClean = modal.trim();
    final lClean = local.trim();
    final endClean = verbClusterEnd.trim();

    String sentence = '';
    String vorfeldPart = '';
    String mittelfeldPart = '';

    final endStr = endClean.isNotEmpty ? ' $endClean' : '';

    if (focus == VorfeldFocusChoice.subjectDefault) {
      // Default: Subject + Verb + Temp + Kaus + Mod + Lok
      final adverbials = [
        if (tClean.isNotEmpty) tClean,
        if (kClean.isNotEmpty) kClean,
        if (mClean.isNotEmpty) mClean,
        if (lClean.isNotEmpty) lClean,
      ];
      mittelfeldPart = adverbials.join(' ');
      sentence = '$sClean $vClean $mittelfeldPart$endStr.'.replaceAll(RegExp(r'\s+'), ' ');
    } else {
      // Focused constituent in Vorfeld -> Inversion: Vorfeld + Verb + Subject + Remaining TeKaMoLo
      List<String> remainingAdverbials = [];

      switch (focus) {
        case VorfeldFocusChoice.temporalFocus:
          vorfeldPart = tClean;
          remainingAdverbials = [
            if (kClean.isNotEmpty) kClean,
            if (mClean.isNotEmpty) mClean,
            if (lClean.isNotEmpty) lClean,
          ];
          break;
        case VorfeldFocusChoice.causalFocus:
          vorfeldPart = kClean;
          remainingAdverbials = [
            if (tClean.isNotEmpty) tClean,
            if (mClean.isNotEmpty) mClean,
            if (lClean.isNotEmpty) lClean,
          ];
          break;
        case VorfeldFocusChoice.modalFocus:
          vorfeldPart = mClean;
          remainingAdverbials = [
            if (tClean.isNotEmpty) tClean,
            if (kClean.isNotEmpty) kClean,
            if (lClean.isNotEmpty) lClean,
          ];
          break;
        case VorfeldFocusChoice.localFocus:
          vorfeldPart = lClean;
          remainingAdverbials = [
            if (tClean.isNotEmpty) tClean,
            if (kClean.isNotEmpty) kClean,
            if (mClean.isNotEmpty) mClean,
          ];
          break;
        default:
          break;
      }

      final capVorfeld = vorfeldPart.isNotEmpty
          ? vorfeldPart[0].toUpperCase() + vorfeldPart.substring(1)
          : '';
      final restAdvStr = remainingAdverbials.isNotEmpty ? ' ${remainingAdverbials.join(' ')}' : '';

      sentence = '$capVorfeld $vClean ${sClean.toLowerCase()}$restAdvStr$endStr.'
          .replaceAll(RegExp(r'\s+'), ' ');
    }

    final rule = 'TeKaMoLo-Topologie: Temporal (Wann?) -> Kausal (Warum?) -> Modal (Wie?) -> Lokal (Wohin/Wo?). Bei Vorfeld-Fokusierung rückt das finite Verb auf Position 2 vor das Subjekt.';
    final arabic = 'ترتيب الظروف (TeKaMoLo): الزمان ثم السبب ثم الكيفية ثم المكان. وعند تصدير أحد الظروف لبؤرة الاهتمام، ينقلب ترتيب الفعل والفاعل فوراً.';

    return TeKaMoLoSequenceStructure(
      focusChoice: focus,
      temporalComponent: tClean,
      causalComponent: kClean,
      modalComponent: mClean,
      localComponent: lClean,
      generatedSentence: sentence,
      followsStrictCanonicalOrder: true,
      topologicalRuleExplanation: rule,
      arabicRuleSummary: arabic,
    );
  }
}
