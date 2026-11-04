/// Task 1565: Hash chain anchor linking lesson completion checkpoints
class CheckpointHashChainAnchor {
  String anchor(String prevHash, String currentBlock) => 'HASH_${prevHash}_$currentBlock';
}
