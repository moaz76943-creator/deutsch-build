import '../../../../language/language_speech_profile.dart';

enum OfflineTtsAvailability { ready, unavailable }

abstract interface class OfflineTtsEngine {
  Future<OfflineTtsAvailability> probe(LanguageSpeechProfile profile);

  Future<bool> speak({
    required String text,
    required LanguageSpeechProfile profile,
    required double rate,
  });

  Future<void> stop();
  Future<void> shutdown();
}
