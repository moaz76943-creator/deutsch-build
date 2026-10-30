/// Conversational persona definition.
class DialoguePersona {
  final String personaId;
  final String displayName;
  final String regionalFlavor; // Standard Hochdeutsch, Berliner Schnauze, Bayerisch
  final String formalityRegister; // formal_buergeramt, casual_peer, culinary_host
  final String greetingPhrase;

  const DialoguePersona({
    required this.personaId,
    required this.displayName,
    required this.regionalFlavor,
    required this.formalityRegister,
    required this.greetingPhrase,
  });
}

/// Dynamically alters AI voice timbre, formality, and cultural demeanor for immersive roleplay.
class MultiPersonaRegisterSwitcher {
  static const Map<String, DialoguePersona> availablePersonas = {
    'official_clerk': DialoguePersona(
      personaId: 'official_clerk',
      displayName: 'Herr Schmidt (Bürgeramt)',
      regionalFlavor: 'Standard Hochdeutsch (Prussian clarity)',
      formalityRegister: 'formal_buergeramt',
      greetingPhrase: 'Guten Tag. Bitte legen Sie Ihren Personalausweis und die Meldebescheinigung vor.',
    ),
    'berlin_peer': DialoguePersona(
      personaId: 'berlin_peer',
      displayName: 'Lukas (Start-up Kollege)',
      regionalFlavor: 'Berlinerisch / Urban Slang',
      formalityRegister: 'casual_peer',
      greetingPhrase: 'Na, alles fit? Hast du Bock auf einen Kaffee?',
    ),
    'bavarian_host': DialoguePersona(
      personaId: 'bavarian_host',
      displayName: 'Franz (Gasthauswirt)',
      regionalFlavor: 'Bairisch / Alpine warmth',
      formalityRegister: 'culinary_host',
      greetingPhrase: 'Grüß Gott beinand! Was darf i euch bringen?',
    ),
  };

  DialoguePersona _activePersona = availablePersonas['official_clerk']!;

  DialoguePersona get activePersona => _activePersona;

  /// Switches active conversational persona.
  void switchPersona(String personaId) {
    final persona = availablePersonas[personaId];
    if (persona != null) {
      _activePersona = persona;
    }
  }
}
