import 'dart:math';
import 'dart:typed_data';

/// Quantized 8-bit vector representation saving 75% memory on mobile devices.
class QuantizedVector {
  final Int8List quantizedBytes;
  final double minVal;
  final double maxVal;

  QuantizedVector({
    required this.quantizedBytes,
    required this.minVal,
    required this.maxVal,
  });

  int get dimension => quantizedBytes.length;
}

/// 8-bit Uniform Scalar Quantizer converting Float32 embedding vectors to Int8.
/// Preserves cosine similarity ordering while drastically cutting RAM usage on Termux.
class VectorScalarQuantizer {
  /// Quantize float32 list to 8-bit signed integers.
  static QuantizedVector quantize(List<double> vector) {
    if (vector.isEmpty) {
      throw ArgumentError('Cannot quantize an empty vector');
    }

    double minVal = vector.first;
    double maxVal = vector.first;

    for (final v in vector) {
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }

    final diff = maxVal - minVal;
    final scale = diff == 0.0 ? 1.0 : 254.0 / diff;

    final quantized = Int8List(vector.length);
    for (int i = 0; i < vector.length; i++) {
      final normalized = ((vector[i] - minVal) * scale) - 127.0;
      quantized[i] = normalized.round().clamp(-127, 127);
    }

    return QuantizedVector(
      quantizedBytes: quantized,
      minVal: minVal,
      maxVal: maxVal,
    );
  }

  /// Dequantize 8-bit representation back to float32 approximation.
  static List<double> dequantize(QuantizedVector qVec) {
    final diff = qVec.maxVal - qVec.minVal;
    final invScale = diff / 254.0;

    final output = List<double>.filled(qVec.dimension, 0.0);
    for (int i = 0; i < qVec.dimension; i++) {
      output[i] = qVec.minVal + ((qVec.quantizedBytes[i] + 127.0) * invScale);
    }
    return output;
  }

  /// Fast dot product on quantized 8-bit integer vectors.
  static int fastQuantizedDotProduct(Int8List a, Int8List b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have identical dimensions');
    }
    int dot = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }
}
