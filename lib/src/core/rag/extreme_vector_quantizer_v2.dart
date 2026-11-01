import 'dart:typed_data';

enum QuantizationMode { oneBitSign, twoBitQuaternary }

class QuantizedVector {
  final int id;
  final int originalDimension;
  final QuantizationMode mode;
  final Uint8List packedData;
  final double scaleFactor;

  const QuantizedVector({required this.id, required this.originalDimension, required this.mode, required this.packedData, required this.scaleFactor});
  int get byteSize => packedData.length;
}

class ExtremeVectorQuantizerV2 {
  final int dimension;
  const ExtremeVectorQuantizerV2({required this.dimension});

  QuantizedVector quantize1Bit(int id, List<double> vector) {
    final bytes = (dimension + 7) ~/ 8;
    final packed = Uint8List(bytes);
    double sum = 0.0;
    for (int i = 0; i < dimension; i++) {
      sum += vector[i].abs();
      if (vector[i] >= 0) packed[i ~/ 8] |= (1 << (i % 8));
    }
    return QuantizedVector(id: id, originalDimension: dimension, mode: QuantizationMode.oneBitSign, packedData: packed, scaleFactor: sum / dimension);
  }

  int hammingDistance(QuantizedVector a, QuantizedVector b) {
    int dist = 0;
    for (int i = 0; i < a.packedData.length; i++) {
      int xor = a.packedData[i] ^ b.packedData[i];
      while (xor > 0) { dist += (xor & 1); xor >>= 1; }
    }
    return dist;
  }
}
