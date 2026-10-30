enum CefrGrade {
  a1,
  a2,
  b1,
  b2,
  c1,
}

class CefrAssessmentResult {
  final CefrGrade detectedLevel;
  final double structuralComplexityScore;
  final List<String> detectedGrammarMarkers;
  final String levelDescriptor;

  const CefrAssessmentResult({
    required this.detectedLevel,
    required this.structuralComplexityScore,
    required this.detectedGrammarMarkers,
    required this.levelDescriptor,
  });

  Map<String, dynamic> toJson() => {
    'detectedLevel': detectedLevel.name.toUpperCase(),
    'structuralComplexityScore': structuralComplexityScore,
    'detectedGrammarMarkers': detectedGrammarMarkers,
    'levelDescriptor': levelDescriptor,
  };
}

class CefrDialogueClassifier {
  const CefrDialogueClassifier();

  /// Classifies a dialogue utterance into European CEFR language proficiency levels.
  CefrAssessmentResult classifyUtterance(String text) {
    final lower = text.trim().toLowerCase();
    final markers = <String>[];
    double complexity = 1.0;

    // C1 markers: extended participial constructions, formal subjunctives (hätte getan, wäre gewesen), passive with modals
    if (lower.contains('infolgedessen') || lower.contains('diesbezüglich') || lower.contains('sei darauf hingewiesen') || lower.contains('zustande gekommen')) {
      markers.add('Advanced C1 Discourse Particle / Academic Connector');
      complexity += 4.0;
    }

    // B2 markers: Konjunktiv II past, Passiv, complex subjunctions (obwohl, anstatt dass, indem)
    if (lower.contains('obwohl') || lower.contains('anstatt') || lower.contains('indem') || lower.contains('wurde') || lower.contains('wäre') || lower.contains('hätte')) {
      markers.add('B2 Subjunctive / Passive / Complex Connector');
      complexity += 3.0;
    }

    // B1 markers: Nebensätze (weil, dass, wenn), modal verbs in past, relative pronouns (der/die/das als Relativpronomen)
    if (lower.contains('weil') || lower.contains('dass') || lower.contains('wenn') || lower.contains('konnte') || lower.contains('musste')) {
      markers.add('B1 Subordinate Clause (Nebensatz) / Modal Preterite');
      complexity += 2.0;
    }

    // A2 markers: Perfekt with haben/sein, direct Akkusativ/Dativ pronouns, basic reflexive (sich freuen)
    if (lower.contains('habe') || lower.contains('ist') && (lower.endsWith('t') || lower.endsWith('en'))) {
      markers.add('A2 Compound Past (Perfekt)');
      complexity += 1.0;
    }

    CefrGrade grade;
    String descriptor;

    if (complexity >= 5.0) {
      grade = CefrGrade.c1;
      descriptor = 'C1: Kompetente Sprachverwendung mit komplexen syntaktischen Verflechtungen.';
    } else if (complexity >= 3.5) {
      grade = CefrGrade.b2;
      descriptor = 'B2: Selbstständige Sprachverwendung mit Passiv und Konjunktiv-Strukturen.';
    } else if (complexity >= 2.5) {
      grade = CefrGrade.b1;
      descriptor = 'B1: Solide Mittelstufe mit korrekter Nebensatz-Syntax (weil/dass).';
    } else if (complexity >= 1.5) {
      grade = CefrGrade.a2;
      descriptor = 'A2: Grundlegende Kenntnisse im Perfekt und Alltagskommunikation.';
    } else {
      grade = CefrGrade.a1;
      descriptor = 'A1: Einstiegsstufe mit elementaren Hauptsätzen und Grundwortschatz.';
    }

    return CefrAssessmentResult(
      detectedLevel: grade,
      structuralComplexityScore: double.parse(complexity.toStringAsFixed(1)),
      detectedGrammarMarkers: markers,
      levelDescriptor: descriptor,
    );
  }
}
