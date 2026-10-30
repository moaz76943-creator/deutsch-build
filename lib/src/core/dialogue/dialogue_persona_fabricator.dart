enum PersonaTemperament {
  formalBureaucratic,
  warmFriendlyPeer,
  authoritativeProfessional,
  patientDeliberateTutor,
}

class SpeechPacingProfile {
  final double rateMultiplier; // e.g. 0.85x for beginners, 1.2x for advanced
  final int interSentencePauseMs;
  final double voicePitchShift;

  const SpeechPacingProfile({
    required this.rateMultiplier,
    required this.interSentencePauseMs,
    this.voicePitchShift = 1.0,
  });
}

class DialoguePersona {
  final String id;
  final String name;
  final String titleRole;
  final PersonaTemperament temperament;
  final SpeechPacingProfile pacing;
  final String systemPromptPersona;
  final String baseGreeting;

  const DialoguePersona({
    required this.id,
    required this.name,
    required this.titleRole,
    required this.temperament,
    required this.pacing,
    required this.systemPromptPersona,
    required this.baseGreeting,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'titleRole': titleRole,
    'temperament': temperament.name,
    'rateMultiplier': pacing.rateMultiplier,
    'interSentencePauseMs': pacing.interSentencePauseMs,
    'baseGreeting': baseGreeting,
  };
}

class DialoguePersonaFabricator {
  static const DialoguePersona herrSchmidt = DialoguePersona(
    id: 'herr_schmidt',
    name: 'Herr Schmidt',
    titleRole: 'Beamter im Bürgeramt / Bahnhof',
    temperament: PersonaTemperament.formalBureaucratic,
    pacing: SpeechPacingProfile(rateMultiplier: 1.05, interSentencePauseMs: 300),
    systemPromptPersona: 'Du bist Herr Schmidt, ein korrekter, formeller deutscher Beamter. Du siezt den Nutzer konsequent und erwartest Höflichkeit.',
    baseGreeting: 'Guten Tag. Bitte legen Sie Ihre Unterlagen vor.',
  );

  static const DialoguePersona anna = DialoguePersona(
    id: 'anna_student',
    name: 'Anna',
    titleRole: 'Studentin / WG-Mitbewohnerin',
    temperament: PersonaTemperament.warmFriendlyPeer,
    pacing: SpeechPacingProfile(rateMultiplier: 1.15, interSentencePauseMs: 180),
    systemPromptPersona: 'Du bist Anna, eine aufgeschlossene 22-jährige Studentin in Berlin. Du sprichst umgangssprachlich, herzlich und locker per Du.',
    baseGreeting: 'Hi! Schön dich kennenzulernen. Wie gehts dir?',
  );

  static const DialoguePersona opaHeinrich = DialoguePersona(
    id: 'opa_heinrich',
    name: 'Opa Heinrich',
    titleRole: 'Geduldiger Sprachbegleiter',
    temperament: PersonaTemperament.patientDeliberateTutor,
    pacing: SpeechPacingProfile(rateMultiplier: 0.82, interSentencePauseMs: 500, voicePitchShift: 0.92),
    systemPromptPersona: 'Du bist Opa Heinrich. Du sprichst ruhig, artikulierst jedes Wort glasklar und ermutigst den Lerner ohne Eile.',
    baseGreeting: 'Hallo mein Lieber. Lass dir alle Zeit der Welt beim Sprechen.',
  );

  const DialoguePersonaFabricator();

  /// Returns persona matching user learning context and preferred pacing.
  DialoguePersona resolvePersona(String personaId) {
    switch (personaId) {
      case 'anna_student':
        return anna;
      case 'opa_heinrich':
        return opaHeinrich;
      case 'herr_schmidt':
      default:
        return herrSchmidt;
    }
  }
}
