import '../language_speech_profile.dart';

final class GermanSpeechProfile implements LanguageSpeechProfile {
  const GermanSpeechProfile();

  @override
  String get languageCode => 'de';

  @override
  List<String> get preferredTtsLocales => const <String>[
        'de-DE',
        'de-AT',
        'de-CH',
        'de',
      ];

  @override
  double get defaultSpeechRate => .46;

  @override
  String get offlineVoiceUnavailableMessage =>
      'German offline TTS voice unavailable';
}
