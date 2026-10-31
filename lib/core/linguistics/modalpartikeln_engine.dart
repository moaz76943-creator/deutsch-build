enum Modalparticle { ja, doch, mal, denn, halt, eben, schon, wohl }

enum PragmaticTone {
  sharedKnowledge,       // ja: تأكيد المعرفة المشتركة (كما نعلم جميعاً)
  rebuttalReminder,      // doch: التذكير بالحجة أو الاعتراض الودي (بل على العكس)
  politeSoftener,        // mal: تلطيف الأمر وإضفاء الودية (من فضلك للحظة)
  interestedInquiry,     // denn: إظهار الاهتمام الودي في السؤال (يا ترى)
  inevitableAcceptance,  // halt / eben: تقبل الأمر الواقع دون تذمر
  reassuranceUrgency,    // schon: التطمين أو الاستعجال
  probableAssumption,    // wohl: الترجيح والظن الغالب
}

class ParticleExplanation {
  final Modalparticle particle;
  final PragmaticTone tone;
  final String arabicGloss;
  final String pedagogicalRule;

  const ParticleExplanation({
    required this.particle,
    required this.tone,
    required this.arabicGloss,
    required this.pedagogicalRule,
  });
}

/// Offline pragmatic engine analyzing German modal particles and their topological constraints.
class ModalpartikelnEngine {
  static const Map<Modalparticle, ParticleExplanation> _catalog = {
    Modalparticle.ja: ParticleExplanation(
      particle: Modalparticle.ja,
      tone: PragmaticTone.sharedKnowledge,
      arabicGloss: 'كما تعلم / بديهياً',
      pedagogicalRule: 'تفيد أن المعلومة معروفة مسبقاً للمتحدث والمستمع (Das weißt du ja).',
    ),
    Modalparticle.doch: ParticleExplanation(
      particle: Modalparticle.doch,
      tone: PragmaticTone.rebuttalReminder,
      arabicGloss: 'بالتأكيد / أليس كذلك؟',
      pedagogicalRule: 'تفيد التذكير بحقيقة واضحة أو تصحيح افتراض خاطئ (Das ist doch klar!).',
    ),
    Modalparticle.mal: ParticleExplanation(
      particle: Modalparticle.mal,
      tone: PragmaticTone.politeSoftener,
      arabicGloss: 'لو سمحت / للحظة',
      pedagogicalRule: 'تخفف حدة صيغة الأمر وتجعله طلباً ودياً ومهذباً (Komm mal her).',
    ),
    Modalparticle.denn: ParticleExplanation(
      particle: Modalparticle.denn,
      tone: PragmaticTone.interestedInquiry,
      arabicGloss: 'يا ترى / إذاً',
      pedagogicalRule: 'تُستخدم في الأسئلة حصراً لإبداء الاهتمام الحقيقي دون فظاظة (Was machst du denn?).',
    ),
    Modalparticle.halt: ParticleExplanation(
      particle: Modalparticle.halt,
      tone: PragmaticTone.inevitableAcceptance,
      arabicGloss: 'هذا هو الواقع',
      pedagogicalRule: 'تعبر عن تقبل أمر واقع لا يمكن تغييره (Das ist halt so).',
    ),
    Modalparticle.wohl: ParticleExplanation(
      particle: Modalparticle.wohl,
      tone: PragmaticTone.probableAssumption,
      arabicGloss: 'على الأرجح / يبدو',
      pedagogicalRule: 'تفيد التخمين المرجح بدرجة عالية من التأكد (Er ist wohl krank).',
    ),
  };

  ParticleExplanation? explain(Modalparticle particle) => _catalog[particle];

  /// التحقق من الموضع النحوي: أداة الخطاب لا تأتي في الحقل الأول (Vorfeld) إطلاقاً.
  bool isValidPosition(int tokenIndex) {
    // يجب أن تكون في حقل الوسط (Mittelfeld) وتأخذ الترتيب بعد الفعل المصرف (tokenIndex > 0)
    return tokenIndex > 0;
  }
}
