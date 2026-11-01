import 'dart:typed_data';

class MmapOfflineVectorBuffer {
  final int vectorDimension;
  final int totalVectors;
  const MmapOfflineVectorBuffer({required this.vectorDimension, required this.totalVectors});

  int getByteOffset(int index) => index * vectorDimension * 4;
}
