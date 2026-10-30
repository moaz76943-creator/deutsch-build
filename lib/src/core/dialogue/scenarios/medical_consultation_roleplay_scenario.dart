enum MedicalPhase {
  greetingAndSymptoms,
  durationAndPainSeverity,
  allergiesAndMedication,
  prescriptionAndSickNote,
  completed,
}

class MedicalCorrectionHint {
  final String originalText;
  final String idiomaticExpression;
  final String explanation;

  const MedicalCorrectionHint({
    required this.originalText,
    required this.idiomaticExpression,
    required this.explanation,
  });
}

class MedicalTurnResult {
  final MedicalPhase nextPhase;
  final String doctorResponse;
  final bool goalAchieved;
  final MedicalCorrectionHint? correctionHint;

  const MedicalTurnResult({
    required this.nextPhase,
    required this.doctorResponse,
    required this.goalAchieved,
    this.correctionHint,
  });
}

class MedicalConsultationRoleplayScenario {
  final String targetLanguage;
  final String cefrLevel;
  MedicalPhase currentPhase;

  MedicalConsultationRoleplayScenario({
    this.targetLanguage = 'de',
    this.cefrLevel = 'A2',
    this.currentPhase = MedicalPhase.greetingAndSymptoms,
  });

  /// Evaluates patient statement and provides medically accurate conversational guidance.
  MedicalTurnResult evaluatePatientTurn(String patientText) {
    final lower = patientText.trim().toLowerCase();
    MedicalCorrectionHint? hint;

    // Detect literal non-idiomatic expression "ich habe Schmerz in Kopf"
    if (lower.contains('schmerz in kopf') || lower.contains('schmerz im kopf')) {
      hint = const MedicalCorrectionHint(
        originalText: 'Schmerz im Kopf',
        idiomaticExpression: 'Ich habe starke Kopfschmerzen / Mein Kopf tut weh',
        explanation: 'In German, body aches are typically expressed using compound nouns like "Kopfschmerzen" or "tut weh".',
      );
    }

    switch (currentPhase) {
      case MedicalPhase.greetingAndSymptoms:
        if (lower.contains('hallo') || lower.contains('guten tag') || lower.contains('wehtun') || lower.contains('schmerzen') || lower.contains('fieber') || lower.contains('husten') || lower.contains('schlecht')) {
          currentPhase = MedicalPhase.durationAndPainSeverity;
          return MedicalTurnResult(
            nextPhase: currentPhase,
            doctorResponse: 'Guten Tag. Nehmen Sie bitte Platz. Was fehlt Ihnen denn und seit wann haben Sie diese Beschwerden?',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return MedicalTurnResult(
          nextPhase: currentPhase,
          doctorResponse: 'Guten Tag! Was kann ich heute für Sie tun?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case MedicalPhase.durationAndPainSeverity:
        if (lower.contains('seit') || lower.contains('tagen') || lower.contains('woche') || lower.contains('stark') || lower.contains('gestern')) {
          currentPhase = MedicalPhase.allergiesAndMedication;
          return MedicalTurnResult(
            nextPhase: currentPhase,
            doctorResponse: 'Ich verstehe. Ich untersuche Sie einmal kurz. Haben Sie irgendwelche Allergien gegen Medikamente?',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return MedicalTurnResult(
          nextPhase: currentPhase,
          doctorResponse: 'Seit wann fühlen Sie sich krank und wie stark sind die Schmerzen auf einer Skala von 1 bis 10?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case MedicalPhase.allergiesAndMedication:
        if (lower.contains('nein') || lower.contains('keine') || lower.contains('allergie') || lower.contains('penicillin') || lower.contains('ja')) {
          currentPhase = MedicalPhase.prescriptionAndSickNote;
          return MedicalTurnResult(
            nextPhase: currentPhase,
            doctorResponse: 'Gut zu wissen. Ich verschreibe Ihnen ein Schmerzmittel und gebe Ihnen eine Arbeitsunfähigkeitsbescheinigung (AU) für drei Tage mit.',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return MedicalTurnResult(
          nextPhase: currentPhase,
          doctorResponse: 'Nehmen Sie zurzeit bereits andere Medikamente ein oder haben Sie bekannte Allergien?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case MedicalPhase.prescriptionAndSickNote:
        if (lower.contains('danke') || lower.contains('rezept') || lower.contains('apotheke') || lower.contains('krankschreibung') || lower.contains('wiedersehen')) {
          currentPhase = MedicalPhase.completed;
          return MedicalTurnResult(
            nextPhase: currentPhase,
            doctorResponse: 'Hier ist Ihr Rezept und Ihre AU. Ruhen Sie sich gut aus und trinken Sie viel Tee. Gute Besserung!',
            goalAchieved: true,
            correctionHint: hint,
          );
        }
        return MedicalTurnResult(
          nextPhase: currentPhase,
          doctorResponse: 'Nehmen Sie die Tabletten bitte zweimal täglich nach dem Essen. Brauchen Sie noch etwas?',
          goalAchieved: false,
          correctionHint: hint,
        );

      case MedicalPhase.completed:
        return const MedicalTurnResult(
          nextPhase: MedicalPhase.completed,
          doctorResponse: 'Das Arztgespräch ist erfolgreich beendet. Gute Besserung!',
          goalAchieved: true,
        );
    }
  }
}
