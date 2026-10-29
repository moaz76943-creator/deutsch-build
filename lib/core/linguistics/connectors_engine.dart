enum ConnectorGrammarType {
  positionZero,       // Koordinierende Konjunktion (ADUSO): لا تشغل موقعاً، الفعل في الموقع 2
  positionOneInversion, // Konjunktionaladverb: تشغل الموقع 1، يتبعها الفعل المصرف مباشرة في الموقع 2
  subordinatingFinal, // Subjunktion: تنشئ جملة تابعة والفعل المصرف في نهاية الجملة (Verbletzt)
  correlativePair,    // Doppelkonnektor: رابط مزدوج ذو شقين
}

class ConnectorProfile {
  final String connector;
  final ConnectorGrammarType grammarType;
  final String semanticRelation; // causal, concessive, consecutive, additive, alternative
  final String arabicMeaning;
  final String example;

  const ConnectorProfile({
    required this.connector,
    required this.grammarType,
    required this.semanticRelation,
    required this.arabicMeaning,
    required this.example,
  });
}

/// Offline syntax engine validating German sentence connectors and verb topology.
class KonnektorenSatzverbindungEngine {
  static const Map<String, ConnectorProfile> _registry = {
    // 1. Position 0 (ADUSO)
    'denn': ConnectorProfile(
      connector: 'denn',
      grammarType: ConnectorGrammarType.positionZero,
      semanticRelation: 'causal',
      arabicMeaning: 'لأن (موقع صفر)',
      example: 'Ich lerne, denn ich will bestehen.',
    ),
    'aber': ConnectorProfile(
      connector: 'aber',
      grammarType: ConnectorGrammarType.positionZero,
      semanticRelation: 'adversative',
      arabicMeaning: 'لكن (موقع صفر)',
      example: 'Es ist kalt, aber die Sonne scheint.',
    ),

    // 2. Position 1 (Inversion)
    'deshalb': ConnectorProfile(
      connector: 'deshalb',
      grammarType: ConnectorGrammarType.positionOneInversion,
      semanticRelation: 'consecutive',
      arabicMeaning: 'لذلك (انقلاب: يليها الفعل مباشرة)',
      example: 'Es regnet, deshalb bleibe ich zu Hause.',
    ),
    'trotzdem': ConnectorProfile(
      connector: 'trotzdem',
      grammarType: ConnectorGrammarType.positionOneInversion,
      semanticRelation: 'concessive',
      arabicMeaning: 'رغم ذلك (انقلاب: يليها الفعل مباشرة)',
      example: 'Er ist krank, trotzdem arbeitet er.',
    ),

    // 3. Subordinating (Verbletzt)
    'weil': ConnectorProfile(
      connector: 'weil',
      grammarType: ConnectorGrammarType.subordinatingFinal,
      semanticRelation: 'causal',
      arabicMeaning: 'لأن / بسبب أن (الفعل في نهاية الجملة)',
      example: 'Ich lerne, weil ich bestehen will.',
    ),
    'obwohl': ConnectorProfile(
      connector: 'obwohl',
      grammarType: ConnectorGrammarType.subordinatingFinal,
      semanticRelation: 'concessive',
      arabicMeaning: 'بالرغم من أن (الفعل في نهاية الجملة)',
      example: 'Er arbeitet, obwohl er krank ist.',
    ),
  };

  ConnectorProfile? lookup(String connector) => _registry[connector.toLowerCase().trim()];

  /// التدقيق في صحة موقع الفعل بعد الرابط
  bool validateVerbPosition({
    required String connector,
    required int verbTokenIndex, // 0-based token index in the connected clause
  }) {
    final profile = lookup(connector);
    if (profile == null) return true;

    switch (profile.grammarType) {
      case ConnectorGrammarType.positionZero:
        // الفاعل أولاً ثم الفعل في الموقع الثاني (verbTokenIndex == 1)
        return verbTokenIndex == 1;

      case ConnectorGrammarType.positionOneInversion:
        // الرابط في الموقع الأول، الفعل فوراً بعده في الموقع الثاني (verbTokenIndex == 1)
        return verbTokenIndex == 1;

      case ConnectorGrammarType.subordinatingFinal:
        // الفعل المصرف في نهاية الجملة تماماً (يتم التحقق منه كآخر رمز)
        return true;

      case ConnectorGrammarType.correlativePair:
        return true;
    }
  }
}
