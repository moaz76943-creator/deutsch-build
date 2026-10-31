/// Sociolinguistic formality register level.
enum FormalityLevel {
  intimate, // Close family / partners
  casual, // Friends, peers, social media
  neutral, // General daily communication
  formal, // Official, bureaucratic, professional, elders
  ceremonial, // High literature, religious, constitutional
}

/// Evaluation of contextual appropriateness and social politeness.
class PragmaticAuditReport {
  final FormalityLevel detectedRegister;
  final FormalityLevel expectedRegister;
  final bool isAppropriate;
  final List<String> flaggedMarkers;
  final String recommendation;

  const PragmaticAuditReport({
    required this.detectedRegister,
    required this.expectedRegister,
    required this.isAppropriate,
    required this.flaggedMarkers,
    required this.recommendation,
  });
}

/// Guards against pragmatic mismatch, honorific violations, and social faux-pas.
class PragmaticRegisterMatrix {
  static const Map<String, FormalityLevel> _germanPronounMarkers = {
    'du': FormalityLevel.casual,
    'dich': FormalityLevel.casual,
    'dir': FormalityLevel.casual,
    'dein': FormalityLevel.casual,
    'sie': FormalityLevel.formal, // Capitalized 'Sie' in usage
    'ihnen': FormalityLevel.formal,
    'ihr': FormalityLevel.casual,
  };

  /// Audits learner utterance for situational register harmony.
  PragmaticAuditReport auditUtterance({
    required String utterance,
    required FormalityLevel targetContext,
  }) {
    final tokens = utterance.toLowerCase().split(RegExp(r'\s+'));
    final flagged = <String>[];
    FormalityLevel detected = FormalityLevel.neutral;

    // Check pronoun honorific indicators
    for (final token in tokens) {
      final clean = token.replaceAll(RegExp(r'[^\w]'), '');
      if (_germanPronounMarkers.containsKey(clean)) {
        final level = _germanPronounMarkers[clean]!;
        if (level == FormalityLevel.casual && targetContext == FormalityLevel.formal) {
          flagged.add(clean);
          detected = FormalityLevel.casual;
        } else if (level == FormalityLevel.formal && targetContext == FormalityLevel.casual) {
          flagged.add(clean);
          detected = FormalityLevel.formal;
        }
      }
    }

    final isMatch = flagged.isEmpty;
    String advice;
    if (!isMatch && targetContext == FormalityLevel.formal) {
      advice = 'Social Faux-Pas Warning: Inadvertent "Duzen" in a formal context. Replace with polite "Sie/Ihnen".';
    } else if (!isMatch && targetContext == FormalityLevel.casual) {
      advice = 'Overly Distant: Using formal address among peers. Adopt informal "du/ihr".';
    } else {
      advice = 'Register Alignment Verified: Formality perfectly matches communicative context.';
    }

    return PragmaticAuditReport(
      detectedRegister: isMatch ? targetContext : detected,
      expectedRegister: targetContext,
      isAppropriate: isMatch,
      flaggedMarkers: flagged,
      recommendation: advice,
    );
  }
}
