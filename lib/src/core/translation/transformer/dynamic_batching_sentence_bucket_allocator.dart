/// Task 1737: Dynamic sentence length bucketing allocator
class SentenceBucketAllocator {
  int assignBucket(int length) => length <= 16 ? 16 : (length <= 32 ? 32 : 64);
}
