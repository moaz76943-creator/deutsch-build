/// Task 2017: BitTorrent-style piece picker prioritizing rarest chunks across swarms
class SwarmDownloadChunkScheduler {
  List<int> scheduleChunks(List<int> pieceRarity) => pieceRarity..sort();
}
