/// Task 1593: Streaming Zstandard/Tar unpacker extracting directly to storage
class PackBundleArchiveStreamer {
  bool isArchiveValid(List<int> header) => header.isNotEmpty && header[0] == 0x28;
}
