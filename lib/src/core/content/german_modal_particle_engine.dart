/// Sentence pragmatic intention or structural mood.
enum SentencePragmaticMood { statement, question, imperative }

/// Semantic nuance conveyed by the modal particle.
enum ParticlePragmaticNuance {
  politeSoftener,       // mal (تلطيف الطلب)
  friendlyEncourager,   // doch (التشجيع / التذكير الإيجابي)
  sharedCommonKnowledge,// ja (التذكير بأمر معلوم للطرفين)
  genuineInterest,      // denn (إظهار الاهتمام الودي في السؤال)
  resignationAcceptance,// halt / eben (التسليم بالواقع / لا حيلة فيه)
  probabilityAssumption,// wohl (الترجيح والاحتمال)
  urgentWarning,        // bloß / nur (التحذير والتشديد)
}

/// Analysis descriptor of an integrated modal particle in a sentence.
class ModalParticleSentenceStructure {
  final String particle;
  final ParticlePragmaticNuance nuance;
  final SentencePragmaticMood mood;
  final String baseSentence;
  final String nuancedSentence;
  final String arabicExplanation;

  ModalParticleSentenceStructure({
    required this.particle,
    required this.nuance,
    required this.mood,
    required this.baseSentence,
    required this.nuancedSentence,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'particle': particle,
        'nuance': nuance.name,
        'mood': mood.name,
        'base': baseSentence,
        'nuanced': nuancedSentence,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine constructing and analyzing German modal particles (Modalpartikeln / Abtönungspartikeln).
/// Injects particles into the Mittelfeld (behind verb/pronoun) to convey authentic native nuances.
class GermanModalParticleEngine {
  static const Map<String, ParticlePragmaticNuance> _particleNuances = {
    'mal': ParticlePragmaticNuance.politeSoftener,
    'doch': ParticlePragmaticNuance.friendlyEncourager,
    'ja': ParticlePragmaticNuance.sharedCommonKnowledge,
    'denn': ParticlePragmaticNuance.genuineInterest,
    'halt': ParticlePragmaticNuance.resignationAcceptance,
    'eben': ParticlePragmaticNuance.resignationAcceptance,
    'wohl': ParticlePragmaticNuance.probabilityAssumption,
    'bloß': ParticlePragmaticNuance.urgentWarning,
    'nur': ParticlePragmaticNuance.urgentWarning,
  };

  /// Insert modal particle into German Mittelfeld and generate Arabic pragmatic context.
  static ModalParticleSentenceStructure injectParticle({
    required String subject,
    required String verb,
    required String particle,
    required String remainder,
    SentencePragmaticMood mood = SentencePragmaticMood.statement,
  }) {
    final cleanParticle = particle.trim().toLowerCase();
    final nuance = _particleNuances[cleanParticle] ?? ParticlePragmaticNuance.politeSoftener;

    String base = '';
    String nuanced = '';
    String arabic = '';

    switch (mood) {
      case SentencePragmaticMood.imperative:
        // Imperative: Verb + (Pronoun) + Particle + Remainder
        final pronounPart = subject.isNotEmpty ? ' $subject' : '';
        base = '$verb$pronounPart $remainder!'.trim();
        nuanced = '$verb$pronounPart $cleanParticle $remainder!'.trim();
        arabic = (cleanParticle == 'mal')
            ? 'تلطيف الأمر وجعله طلباً ودياً عابراً'
            : (cleanParticle == 'doch' ? 'تشجيع وحث ودود على التجربة' : 'تحذير مشدد');
        break;

      case SentencePragmaticMood.question:
        // Question: (W-Word) + Verb + Subject + Particle + Remainder
        base = '$verb $subject $remainder?'.trim();
        nuanced = '$verb $subject $cleanParticle $remainder?'.trim();
        arabic = (cleanParticle == 'denn')
            ? 'إظهار الاهتمام أو التعجب الودي في السؤال'
            : 'استفسار احتمالي';
        break;

      case SentencePragmaticMood.statement:
        // Statement: Subject + Verb + Particle + Remainder
        base = '$subject $verb $remainder.'.trim();
        nuanced = '$subject $verb $cleanParticle $remainder.'.trim();
        if (cleanParticle == 'ja') {
          arabic = 'تذكير بمعلومة معروفة ومسلّم بها لدى الطرفين';
        } else if (cleanParticle == 'doch') {
          arabic = 'تأكيد معنوي لطيف وتصحيح افتراض سابق';
        } else if (cleanParticle == 'halt' || cleanParticle == 'eben') {
          arabic = 'تسليم بالأمر الواقع وتقبله دون اعتراض';
        } else {
          arabic = 'ترجيح واحتمال (على الأرجح)';
        }
        break;
    }

    return ModalParticleSentenceStructure(
      particle: cleanParticle,
      nuance: nuance,
      mood: mood,
      baseSentence: base,
      nuancedSentence: nuanced,
      arabicExplanation: arabic,
    );
  }
}
