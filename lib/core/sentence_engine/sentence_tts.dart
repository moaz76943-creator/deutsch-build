typedef SentenceTtsSpeakCallback = Future<void> Function(
  String text,
  String languageCode,
);

abstract interface class SentenceTtsHook {
  bool get isOfflineReady;

  Future<void> speak(
    String text, {
    String languageCode = 'de-DE',
  });

  Future<void> stop();
}

final class CallbackSentenceTtsHook implements SentenceTtsHook {
  const CallbackSentenceTtsHook({
    required this.offlineReady,
    required this.speakCallback,
    this.stopCallback,
  });

  final bool offlineReady;
  final SentenceTtsSpeakCallback speakCallback;
  final Future<void> Function()? stopCallback;

  @override
  bool get isOfflineReady => offlineReady;

  @override
  Future<void> speak(
    String text, {
    String languageCode = 'de-DE',
  }) =>
      speakCallback(text, languageCode);

  @override
  Future<void> stop() async {
    final callback = stopCallback;
    if (callback != null) {
      await callback();
    }
  }
}
