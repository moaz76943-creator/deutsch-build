class TamperEvidentLearningJournalLedger {
  final List<String> blockHashes = [];
  void appendBlock(String hash) => blockHashes.add(hash);
}
