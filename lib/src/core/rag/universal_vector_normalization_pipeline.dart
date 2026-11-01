import 'dart:math' as math;

class UniversalVectorNormalizationPipeline {
  final int dimension;
  final List<double> meanVector;
  final List<double> scaleFactors;

  UniversalVectorNormalizationPipeline({required this.dimension, List<double>? mean, List<double>? scale})
      : meanVector = mean ?? List.filled(dimension, 0.0),
        scaleFactors = scale ?? List.filled(dimension, 1.0);

  List<double> transform(List<double> raw) {
    final whitened = List<double>.filled(dimension, 0.0);
    double sumSq = 0.0;
    for (int i = 0; i < dimension; i++) {
      final centered = (raw[i] - meanVector[i]) * scaleFactors[i];
      whitened[i] = centered;
      sumSq += centered * centered;
    }
    final norm = math.sqrt(sumSq);
    if (norm < 1e-12) return whitened;
    for (int i = 0; i < dimension; i++) {
      whitened[i] /= norm;
    }
    return whitened;
  }
}
