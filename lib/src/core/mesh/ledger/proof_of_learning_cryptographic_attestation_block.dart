/// Task 1563: Cryptographic proof-of-learning block
class ProofOfLearningBlock {
  Map<String, dynamic> createBlock(String studentDid, String lessonCid, int score, String sig) => {'did': studentDid, 'lesson': lessonCid, 'score': score, 'sig': sig};
}
