/// سياسة إدارة مجمّع مشغلات الصوت للحد من استهلاك الذاكرة
class AudioPoolPolicy {
  final int maxActivePlayers;
  final Duration playbackTimeout;

  const AudioPoolPolicy({
    this.maxActivePlayers = 3,
    this.playbackTimeout = const Duration(seconds: 15),
  });

  bool canAllocate(int currentActiveCount) {
    return currentActiveCount < maxActivePlayers;
  }
}
