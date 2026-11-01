import 'dart:typed_data';

class ZeroAllocationMemoryPool {
  final int blockSize;
  final List<Uint8List> _availableBlocks;

  ZeroAllocationMemoryPool({this.blockSize = 4096, int poolCapacity = 16})
      : _availableBlocks = List.generate(poolCapacity, (_) => Uint8List(blockSize));

  Uint8List? acquireBlock() => _availableBlocks.isNotEmpty ? _availableBlocks.removeLast() : null;
  void releaseBlock(Uint8List block) => _availableBlocks.add(block);
}
