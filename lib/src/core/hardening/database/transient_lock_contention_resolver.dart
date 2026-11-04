/// Task 1025: Busy handler & exponential backoff for concurrent writes
class LockContentionResolver {
  int retries = 0;
  Future<bool> retryBackoff(int attempt) async {
    retries++;
    return attempt < 5;
  }
}
