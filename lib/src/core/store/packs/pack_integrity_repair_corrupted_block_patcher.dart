class PackIntegrityRepairCorruptedBlockPatcher {
  List<int> patchCorruptedBlock(List<int> pack, int blockIndex, List<int> validBlock) {
    return List.from(pack)..setRange(blockIndex, blockIndex + validBlock.length, validBlock);
  }
}
