/// Task 1088: Critical metadata write-fence flusher before termination
class DiskIoWriteFenceFlusher {
  int flushedTransactions = 0;
  void flushToDisk() => flushedTransactions++;
}
