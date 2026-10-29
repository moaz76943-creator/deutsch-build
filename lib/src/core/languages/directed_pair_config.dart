import 'declarative_language_profile.dart';

/// Configuration for a specific asymmetric directed learning path (Source -> Target).
class DirectedPairConfig {
  final String sourceIso;
  final String targetIso;
  final double cognitiveFrictionScore; // 0.0 (identical) to 3.0 (extreme typology divergence)
  final List<String> primaryInterferenceAreas;
  final bool requiresBidiFlipping; // true if one is RTL and other is LTR

  const DirectedPairConfig({
    required this.sourceIso,
    required this.targetIso,
    required this.cognitiveFrictionScore,
    required this.primaryInterferenceAreas,
    required this.requiresBidiFlipping,
  });

  String get pairId => '${sourceIso.toLowerCase()}_${targetIso.toLowerCase()}';

  Map<String, dynamic> toJson() => {
    'pairId': pairId,
    'sourceIso': sourceIso,
    'targetIso': targetIso,
    'cognitiveFrictionScore': cognitiveFrictionScore,
    'primaryInterferenceAreas': primaryInterferenceAreas,
    'requiresBidiFlipping': requiresBidiFlipping,
  };
}
