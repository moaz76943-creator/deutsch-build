abstract interface class LanguageSpeechProfile {
  String get languageCode;
  List<String> get preferredTtsLocales;
  double get defaultSpeechRate;
  String get offlineVoiceUnavailableMessage;
}
