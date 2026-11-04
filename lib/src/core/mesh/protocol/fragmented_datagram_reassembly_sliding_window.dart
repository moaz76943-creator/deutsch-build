/// Task 1516: Sliding window datagram packet reassembler
class DatagramSlidingWindow {
  final Map<int, List<int>> _chunks = {};
  void addPacket(int seq, List<int> data) => _chunks[seq] = data;
  bool isComplete(int total) => _chunks.length >= total;
}
