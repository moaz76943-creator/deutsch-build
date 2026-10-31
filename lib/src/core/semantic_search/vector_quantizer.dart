/// Quantized 8-bit integer vector to minimize on-device memory footprint.
class QuantizedVector {
  final List<int> quantizedBytes; // Int8 values (-128 to 127)
  final double scale;
  final double zeroPoint;

  const QuantizedVector({
    required this.quantizedBytes,
    required this.scale,
    required this.zeroPoint,
  });

  int get byteSize => quantizedBytes.length;
}

/// Compresses float32 dense embeddings into compact 8-bit vectors with minimal fidelity loss.
class VectorQuantizer {
  /// Compresses a 32-bit floating point vector into int8 quantized form.
  QuantizedVector quantize(List<double> floatVector) {
    if (floatVector.isEmpty) {
      return const QuantizedVector(quantizedBytes: [], scale: 1.0, zeroPoint: 0.0);
    }

    double minVal = floatVector.first;
    double maxVal = floatVector.first;

    for (final v in floatVector) {
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }

    if (maxVal == minVal) {
      return QuantizedVector(
        quantizedBytes: List<int>.filled(floatVector.length, 0),
        scale: 1.0,
        zeroPoint: 0.0,
      );
    }

    // Map [minVal, maxVal] to [-128, 127] (range 255)
    final scale = (maxVal - minVal) / 255.0;
    final zeroPoint = -128.0 - (minVal / scale);

    final bytes = List<int>.filled(floatVector.length, 0);
    for (int i = 0; i < floatVector.length; i++) {
      final q = ((floatVector[i] / scale) + zeroPoint).round();
      bytes[i] = q.clamp(-128, 127);
    }

    return QuantizedVector(
      quantizedBytes: bytes,
      scale: scale,
      zeroPoint: zeroPoint,
    );
  }

  /// Dequantizes int8 bytes back to approximate float32 vector.
  List<double> dequantize(QuantizedVector qVec) {
    final result = List<double>.filled(qVec.quantizedBytes.length, 0.0);
    for (int i = 0; i < qVec.quantizedBytes.length; i++) {
      result[i] = (qVec.quantizedBytes[i] - qVec.zeroPoint) * qVec.scale;
    }
    return result;
  }

  /// Estimates memory reduction percentage (float32 is 4 bytes, int8 is 1 byte -> 75% reduction).
  double calculateCompressionSavings(int vectorDimension) {
    final rawBytes = vectorDimension * 4;
    final quantizedBytes = vectorDimension * 1;
    return ((rawBytes - quantizedBytes) / rawBytes) * 100.0;
  }
}
