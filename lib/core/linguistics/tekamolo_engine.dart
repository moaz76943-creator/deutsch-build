/// Adverbial semantic classification for German topological Mittelfeld.
enum AdverbialType {
  temporal,  // Temporal: Wann? (Te)
  kausal,    // Kausal: Warum? (Ka)
  modal,     // Modal: Wie? (Mo)
  lokal,     // Lokal: Wohin / Wo? (Lo)
  other,
}

class AdverbialSegment {
  final String text;
  final AdverbialType type;

  const AdverbialSegment(this.text, this.type);
}

class TeKaMoLoResult {
  final bool isValid;
  final List<AdverbialSegment> segments;
  final List<String> violations;

  const TeKaMoLoResult({
    required this.isValid,
    required this.segments,
    required this.violations,
  });
}

/// Offline rule validator for German TeKaMoLo sentence topology.
class TeKaMoLoEngine {
  static const List<AdverbialType> canonicalSequence = [
    AdverbialType.temporal,
    AdverbialType.kausal,
    AdverbialType.modal,
    AdverbialType.lokal,
  ];

  TeKaMoLoResult validateOrder(List<AdverbialSegment> segments) {
    final violations = <String>[];
    int highestObservedIndex = -1;

    for (final segment in segments) {
      if (segment.type == AdverbialType.other) continue;
      final currentIndex = canonicalSequence.indexOf(segment.type);

      if (currentIndex < highestObservedIndex) {
        violations.add(
          'Topological Inversion: "${segment.text}" (${segment.type.name}) placed after higher rank constituent.',
        );
      } else {
        highestObservedIndex = currentIndex;
      }
    }

    return TeKaMoLoResult(
      isValid: violations.isEmpty,
      segments: List.unmodifiable(segments),
      violations: violations,
    );
  }
}
