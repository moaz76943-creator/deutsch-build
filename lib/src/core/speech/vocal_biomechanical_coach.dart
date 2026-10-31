class BiomechanicalGuidance {
  final String phoneme;
  final String tonguePosition;
  final String lipShape;
  final String vocalCordState;
  final String visualTip;

  const BiomechanicalGuidance({
    required this.phoneme,
    required this.tonguePosition,
    required this.lipShape,
    required this.vocalCordState,
    required this.visualTip,
  });
}

class VocalBiomechanicalCoach {
  static const Map<String, BiomechanicalGuidance> _guides = {
    'y': BiomechanicalGuidance(
      phoneme: 'ü [y]',
      tonguePosition: 'High front (same as /i/)',
      lipShape: 'Tightly rounded / pursed forward',
      vocalCordState: 'Voiced',
      visualTip: 'Say "ee" and push your lips into a tight whistle shape without moving your tongue.',
    ),
    'ø': BiomechanicalGuidance(
      phoneme: 'ö [ø]',
      tonguePosition: 'Mid front (same as /e/)',
      lipShape: 'Rounded into an oval',
      vocalCordState: 'Voiced',
      visualTip: 'Say "ay" and round your lips into an "o" shape.',
    ),
    'ç': BiomechanicalGuidance(
      phoneme: 'ich-Laut [ç]',
      tonguePosition: 'Arch arched against hard palate',
      lipShape: 'Neutral unrounded',
      vocalCordState: 'Voiceless friction',
      visualTip: 'Whisper "yes" or hiss like a gentle cat; keep tongue near roof of mouth.',
    ),
  };

  const VocalBiomechanicalCoach();

  BiomechanicalGuidance? getGuidance(String phonemeKey) => _guides[phonemeKey];
}
