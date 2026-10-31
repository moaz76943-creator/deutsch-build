enum InterviewPhase {
  formalGreeting,
  selfIntroductionAndExperience,
  strengthsAndProjects,
  availabilityAndNoticePeriod,
  candidateQuestions,
  completed,
}

class InterviewFeedbackHint {
  final String originalText;
  final String formalRecommendation;
  final String explanation;

  const InterviewFeedbackHint({
    required this.originalText,
    required this.formalRecommendation,
    required this.explanation,
  });
}

class InterviewTurnResult {
  final InterviewPhase nextPhase;
  final String interviewerResponse;
  final bool goalAchieved;
  final InterviewFeedbackHint? feedbackHint;

  const InterviewTurnResult({
    required this.nextPhase,
    required this.interviewerResponse,
    required this.goalAchieved,
    this.feedbackHint,
  });
}

class JobInterviewRoleplayScenario {
  final String targetLanguage;
  final String cefrLevel;
  InterviewPhase currentPhase;

  JobInterviewRoleplayScenario({
    this.targetLanguage = 'de',
    this.cefrLevel = 'B2',
    this.currentPhase = InterviewPhase.formalGreeting,
  });

  /// Evaluates candidate response in formal professional context.
  InterviewTurnResult evaluateCandidateTurn(String candidateText) {
    final lower = candidateText.trim().toLowerCase();
    InterviewFeedbackHint? hint;

    // Detect informal "du/dir/dein" in formal German interview
    if (lower.contains(' du ') || lower.startsWith('du ') || lower.contains(' dir ') || lower.contains(' dein')) {
      hint = const InterviewFeedbackHint(
        originalText: 'du / dir',
        formalRecommendation: 'Sie / Ihnen',
        explanation: 'In German professional job interviews, always use the formal address "Sie/Ihnen".',
      );
    }

    switch (currentPhase) {
      case InterviewPhase.formalGreeting:
        if (lower.contains('guten tag') || lower.contains('freut mich') || lower.contains('hoffmann')) {
          currentPhase = InterviewPhase.selfIntroductionAndExperience;
          return InterviewTurnResult(
            nextPhase: currentPhase,
            interviewerResponse: 'Guten Tag! Nehmen Sie bitte Platz. Erzählen Sie mir doch kurz etwas über Ihren beruflichen Werdegang.',
            goalAchieved: true,
            feedbackHint: hint,
          );
        }
        return InterviewTurnResult(
          nextPhase: currentPhase,
          interviewerResponse: 'Guten Tag! Willkommen bei uns. Haben Sie gut hergefunden?',
          goalAchieved: false,
          feedbackHint: hint,
        );

      case InterviewPhase.selfIntroductionAndExperience:
        if (lower.contains('erfahrung') || lower.contains('gearbeitet') || lower.contains('studium') || lower.contains('bereich') || lower.contains('jahre')) {
          currentPhase = InterviewPhase.strengthsAndProjects;
          return InterviewTurnResult(
            nextPhase: currentPhase,
            interviewerResponse: 'Das klingt sehr spannend. Welche besonderen Stärken bringen Sie für diese Position mit?',
            goalAchieved: true,
            feedbackHint: hint,
          );
        }
        return InterviewTurnResult(
          nextPhase: currentPhase,
          interviewerResponse: 'Können Sie Ihre bisherigen praktischen Erfahrungen kurz zusammenfassen?',
          goalAchieved: false,
          feedbackHint: hint,
        );

      case InterviewPhase.strengthsAndProjects:
        if (lower.contains('stärke') || lower.contains('team') || lower.contains('lösung') || lower.contains('zuverlässig') || lower.contains('projekt')) {
          currentPhase = InterviewPhase.availabilityAndNoticePeriod;
          return InterviewTurnResult(
            nextPhase: currentPhase,
            interviewerResponse: 'Sehr gut. Ab wann wären Sie für unser Team verfügbar und wie lang ist Ihre Kündigungsfrist?',
            goalAchieved: true,
            feedbackHint: hint,
          );
        }
        return InterviewTurnResult(
          nextPhase: currentPhase,
          interviewerResponse: 'Was zeichnet Ihre Arbeitsweise im Team besonders aus?',
          goalAchieved: false,
          feedbackHint: hint,
        );

      case InterviewPhase.availabilityAndNoticePeriod:
        if (lower.contains('sofort') || lower.contains('monat') || lower.contains('kündigungsfrist') || lower.contains('wochen') || lower.contains('ab')) {
          currentPhase = InterviewPhase.candidateQuestions;
          return InterviewTurnResult(
            nextPhase: currentPhase,
            interviewerResponse: 'Ausgezeichnet. Haben Sie noch offene Fragen an uns oder zu unserem Arbeitsumfeld?',
            goalAchieved: true,
            feedbackHint: hint,
          );
        }
        return InterviewTurnResult(
          nextPhase: currentPhase,
          interviewerResponse: 'Wann könnten Sie frühestens bei uns anfangen?',
          goalAchieved: false,
          feedbackHint: hint,
        );

      case InterviewPhase.candidateQuestions:
        if (lower.contains('team') || lower.contains('weiterbildung') || lower.contains('kultur') || lower.contains('danke')) {
          currentPhase = InterviewPhase.completed;
          return InterviewTurnResult(
            nextPhase: currentPhase,
            interviewerResponse: 'Vielen Dank für das angenehme und aufschlussreiche Gespräch. Wir melden uns bis Ende der Woche bei Ihnen!',
            goalAchieved: true,
            feedbackHint: hint,
          );
        }
        return InterviewTurnResult(
          nextPhase: currentPhase,
          interviewerResponse: 'Möchten Sie noch etwas über unsere Einarbeitung oder das Projektteam wissen?',
          goalAchieved: false,
          feedbackHint: hint,
        );

      case InterviewPhase.completed:
        return const InterviewTurnResult(
          nextPhase: InterviewPhase.completed,
          interviewerResponse: 'Das Bewerbungsgespräch ist erfolgreich beendet. Viel Erfolg!',
          goalAchieved: true,
        );
    }
  }
}
