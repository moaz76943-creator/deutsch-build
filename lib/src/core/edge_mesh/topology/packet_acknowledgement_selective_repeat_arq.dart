/// Task 2013: Selective-repeat ARQ pipeline guaranteeing reliable delivery over BLE
class SelectiveRepeatArqPipeline {
  bool isAcked(int seqNum, Set<int> ackSet) => ackSet.contains(seqNum);
}
