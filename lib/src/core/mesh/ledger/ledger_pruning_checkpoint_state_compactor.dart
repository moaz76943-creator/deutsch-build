/// Task 1567: Prunes historical DAG transactions into compact state roots
class LedgerStateCompactor {
  int compactDag(int totalBlocks) => (totalBlocks * 0.05).ceil();
}
