enum CefrLevel { a1, a2, b1, b2, unknown }

class CefrClassifier {
  static CefrLevel detectLevel(int frequencyRank, int charLength) {
    if (frequencyRank <= 500 && charLength <= 6) return CefrLevel.a1;
    if (frequencyRank <= 1500) return CefrLevel.a2;
    if (frequencyRank <= 3000) return CefrLevel.b1;
    return CefrLevel.b2;
  }

  static String getLabel(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1:
        return 'A1 (Grundstufe)';
      case CefrLevel.a2:
        return 'A2 (Aufbau)';
      case CefrLevel.b1:
        return 'B1 (Fortgeschritten)';
      case CefrLevel.b2:
        return 'B2 (Professionell)';
      default:
        return 'Alltag';
    }
  }
}
