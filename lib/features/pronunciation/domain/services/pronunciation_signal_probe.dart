import '../pronunciation_models.dart';

abstract interface class PronunciationSignalProbe {
  Future<bool> requestPermission();

  Future<PronunciationSignalCapture> capture({
    Duration maxDuration = const Duration(milliseconds: 1600),
  });
}

final class UnavailablePronunciationSignalProbe
    implements PronunciationSignalProbe {
  const UnavailablePronunciationSignalProbe();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<PronunciationSignalCapture> capture({
    Duration maxDuration = const Duration(milliseconds: 1600),
  }) async =>
      const PronunciationSignalCapture.unavailable(
        'pronunciation_signal_probe_unavailable',
      );
}
