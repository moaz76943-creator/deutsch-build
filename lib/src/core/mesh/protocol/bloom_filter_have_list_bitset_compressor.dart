/// Task 1514: Compressed Bloom filter summarizing peer pack inventory
class BloomFilterCompressor {
  bool mightContain(int bitset, int hashVal) => (bitset & (1 << (hashVal % 16))) != 0;
}
