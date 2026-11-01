import 'dart:typed_data';

class SimdVectorMathEngine {
  const SimdVectorMathEngine();

  double dotProduct(Float32List a, Float32List b) {
    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      sum += a[i] * b[i];
    }
    return sum;
  }
}
