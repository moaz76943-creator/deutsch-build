import '../language_speech_profile.dart';

final class ArabicSpeechProfile implements LanguageSpeechProfile {
  const ArabicSpeechProfile();

  @override
  String get languageCode => 'ar';

  @override
  List<String> get preferredTtsLocales => const <String>[
        'ar-JO',
        'ar-SA',
        'ar-EG',
        'ar',
      ];

  @override
  double get defaultSpeechRate => .45;

  @override
  String get offlineVoiceUnavailableMessage =>
      'Arabic offline TTS voice unavailable';
}
