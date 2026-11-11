/// Deictic vector orientation relative to the speaker.
enum DeicticOrientation {
  towardsSpeaker, // her- (باتجاه المتكلم)
  awayFromSpeaker, // hin- (مبتعداً عن المتكلم)
}

/// Base spatial trajectory.
enum SpatialTrajectory {
  inward,   // ein (إلى الداخل)
  outward,  // aus (إلى الخارج)
  upward,   // auf (إلى الأعلى)
  downward, // unter / ab (إلى الأسفل)
  across,   // über (إلى الجهة المقابلة)
}

/// Analysis descriptor of an engineered directional adverb phrase.
class DirectionalAdverbStructure {
  final DeicticOrientation orientation;
  final SpatialTrajectory trajectory;
  final String formalStandardForm; // e.g. "hinein", "heraus", "hinauf"
  final String spokenContraction;  // e.g. "rein", "raus", "rauf"
  final String sampleSentence;
  final String perspectiveExplanation;
  final String arabicEquivalence;

  DirectionalAdverbStructure({
    required this.orientation,
    required this.trajectory,
    required this.formalStandardForm,
    required this.spokenContraction,
    required this.sampleSentence,
    required this.perspectiveExplanation,
    required this.arabicEquivalence,
  });

  Map<String, dynamic> toJson() => {
        'orientation': orientation.name,
        'trajectory': trajectory.name,
        'formal': formalStandardForm,
        'spoken': spokenContraction,
        'sentence': sampleSentence,
        'perspective': perspectiveExplanation,
        'arabic': arabicEquivalence,
      };
}

/// Offline rule engine constructing and validating German Directional Adverbs (Direktionaladverbien).
/// Models the deictic spatial contrast between "hin-" (motion away from speaker)
/// and "her-" (motion towards speaker), along with spoken colloquial "r-" contractions.
class GermanDirectionalAdverbsEngine {
  /// Compute directional compound adverb based on orientation and spatial trajectory.
  static DirectionalAdverbStructure computeDirectionalCompound({
    required DeicticOrientation orientation,
    required SpatialTrajectory trajectory,
    String? subject,
    String? movementVerb,
  }) {
    String formal = '';
    String spoken = '';
    String perspective = '';
    String arabic = '';

    final isTowards = orientation == DeicticOrientation.towardsSpeaker;

    switch (trajectory) {
      case SpatialTrajectory.inward:
        formal = isTowards ? 'herein' : 'hinein';
        spoken = 'rein';
        perspective = isTowards ? 'حركة داخلة نحو موقع المتكلم' : 'حركة داخلة مبتعدة عن المتكلم';
        arabic = isTowards ? 'ادخل إلى هنا (عندي)' : 'ادخل إلى هناك (بعيداً عني)';
        break;

      case SpatialTrajectory.outward:
        formal = isTowards ? 'heraus' : 'hinaus';
        spoken = 'raus';
        perspective = isTowards ? 'حركة خارجة باتجاه المتكلم' : 'حركة خارجة مبتعدة عن المتكلم';
        arabic = isTowards ? 'اخرج إلى هنا' : 'اخرج إلى هناك';
        break;

      case SpatialTrajectory.upward:
        formal = isTowards ? 'herauf' : 'hinauf';
        spoken = 'rauf';
        perspective = isTowards ? 'حركة صاعدة نحو المتكلم' : 'حركة صاعدة مبتعدة عن المتكلم';
        arabic = isTowards ? 'اصعد إلى هنا (عندي)' : 'اصعد إلى هناك';
        break;

      case SpatialTrajectory.downward:
        formal = isTowards ? 'herunter' : 'hinunter';
        spoken = 'runter';
        perspective = isTowards ? 'حركة نازلة نحو المتكلم' : 'حركة نازلة مبتعدة عن المتكلم';
        arabic = isTowards ? 'انزل إلى هنا (عندي)' : 'انزل إلى هناك';
        break;

      case SpatialTrajectory.across:
        formal = isTowards ? 'herüber' : 'hinüber';
        spoken = 'rüber';
        perspective = isTowards ? 'عبور إلى جهة المتكلم' : 'عبور إلى الجهة المقابلة مبتعداً';
        arabic = isTowards ? 'اعبر إلى جهتي' : 'اعبر إلى الجهة الأخرى';
        break;
    }

    final subj = subject ?? (isTowards ? 'Du' : 'Er');
    final verb = movementVerb ?? 'kommt';
    final sentence = '$subj $verb $formal.'.trim();

    return DirectionalAdverbStructure(
      orientation: orientation,
      trajectory: trajectory,
      formalStandardForm: formal,
      spokenContraction: spoken,
      sampleSentence: sentence,
      perspectiveExplanation: perspective,
      arabicEquivalence: arabic,
    );
  }
}
