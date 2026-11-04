/// Task 1032: Batch transaction chunking & rate limiter preventing UI frame drops
class BatchTransactionLimiter {
  static const int maxChunkSize = 250;
  int calculateChunks(int totalRecords) => (totalRecords / maxChunkSize).ceil();
}
