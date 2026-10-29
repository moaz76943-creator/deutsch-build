enum ReferentNature { person, objectOrConcept }

class PronominalResult {
  final String statementForm;    // e.g. daran / an ihn
  final String questionForm;     // e.g. woran / an wen
  final bool isPronominalAdverb; // true for da(r)-/wo(r)-, false for preposition + pronoun
  final String pedagogicalRule;

  const PronominalResult({
    required this.statementForm,
    required this.questionForm,
    required this.isPronominalAdverb,
    required this.pedagogicalRule,
  });
}

/// Offline engine generating and validating German Pronominaladverbien (da-/wo- compounds).
class PronominaladverbienEngine {
  static const Set<String> _vowelInitialPrepositions = {
    'an', 'auf', 'in', 'über', 'unter', 'um', 'aus'
  };

  /// يولد الصيغة الصحيحة للإشارة أو السؤال بناءً على طبيعة المشار إليه (شخص vs شيء/فكرة)
  PronominalResult generate({
    required String preposition,
    required ReferentNature referent,
    String? personalPronoun, // مثال: 'ihn', 'sie', 'ihm'
    String? questionPronoun,  // مثال: 'wen', 'wem'
  }) {
    final prep = preposition.toLowerCase().trim();

    if (referent == ReferentNature.person) {
      final pPron = personalPronoun ?? 'ihn/sie';
      final qPron = questionPronoun ?? 'wen/wem';
      return PronominalResult(
        statementForm: '$prep $pPron',
        questionForm: '$prep $qPron',
        isPronominalAdverb: false,
        pedagogicalRule: 'للأشخاص: نستخدم حرف الجر متبوعاً بضمير شخصي حصراً (Ich denke an ihn / An wen?).',
      );
    }

    // للأشياء والمفاهيم: تركيب da(r)- و wo(r)-
    final requiresR = _vowelInitialPrepositions.contains(prep) ||
        prep.startsWith('a') || prep.startsWith('e') ||
        prep.startsWith('i') || prep.startsWith('o') ||
        prep.startsWith('u') || prep.startsWith('ü');

    final daPrefix = requiresR ? 'dar' : 'da';
    final woPrefix = requiresR ? 'wor' : 'wo';

    final statement = '$daPrefix$prep';
    final question = '$woPrefix$prep';

    return PronominalResult(
      statementForm: statement,
      questionForm: question,
      isPronominalAdverb: true,
      pedagogicalRule: requiresR
          ? 'للأشياء: دمج da(r)- مع إدخال حرف r لمنع التقاء حرفي علة ($statement / $question).'
          : 'للأشياء: دمج da- و wo- مباشرة مع حرف الجر المبتدئ بحرف ساكن ($statement / $question).',
    );
  }

  /// كشف ومنع الخطأ الشائع: استخدام da-/wo- مع الأشخاص
  bool isIllegalPersonCombination(String text) {
    final lower = text.toLowerCase();
    // تحذير إذا استُخدم مركب da- للإشارة لشخص (مثل: *Ich warte darauf [für den Lehrer])
    return lower.startsWith('da') || lower.startsWith('wo');
  }
}
