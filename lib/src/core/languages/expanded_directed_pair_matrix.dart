import 'dart:math';
import 'declarative_language_profile.dart';
import 'language_topology_vector.dart';

/// Calculates asymmetric learning distance and FSRS-5 difficulty factor between any two languages.
class ExpandedDirectedPairMatrix {
  const ExpandedDirectedPairMatrix();

  /// Computes asymmetric directional distance D(Source -> Target).
  double computeDirectionalFriction(LanguageProfile source, LanguageProfile target) {
    final vS = LanguageTopologyVector.fromProfile(source);
    final vT = LanguageTopologyVector.fromProfile(target);

    // Directional friction: moving from simple to complex is harder than complex to simple
    double distance = 0.0;

    // 1. Script directionality flip penalty
    if (vS.directionalityScore != vT.directionalityScore) {
      distance += 0.40;
    }

    // 2. Typology divergence
    distance += (vS.typologyScore - vT.typologyScore).abs() * 0.25;

    // 3. Case acquisition friction (harder to acquire more cases)
    if (vT.caseSystemWeight > vS.caseSystemWeight) {
      distance += (vT.caseSystemWeight - vS.caseSystemWeight) * 0.8;
    } else {
      distance += (vS.caseSystemWeight - vT.caseSystemWeight) * 0.15;
    }

    // 4. Morphology shift (e.g. Fusional to Agglutinative)
    distance += (vS.morphologyScore - vT.morphologyScore).abs() * 0.30;

    // 5. Gender expansion
    if (vT.genderComplexity > vS.genderComplexity) {
      distance += (vT.genderComplexity - vS.genderComplexity) * 0.35;
    }

    return double.parse(distance.clamp(0.2, 3.5).toStringAsFixed(2));
  }
}
