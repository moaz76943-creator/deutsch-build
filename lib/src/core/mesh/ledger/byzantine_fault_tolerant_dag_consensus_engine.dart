/// Task 1564: Lightweight asynchronous BFT / virtual gossip consensus
class BftDagConsensusEngine {
  bool hasBftQuorum(int approvals, int totalNodes) => approvals > (totalNodes * 2 / 3);
}
