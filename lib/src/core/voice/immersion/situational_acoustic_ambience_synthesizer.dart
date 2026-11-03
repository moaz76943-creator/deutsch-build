/// Task 1181: Offline spatial background acoustic ambiance generator
class SituationalAmbienceSynthesizer {
  String activeAmbience = 'QUIET_LIBRARY';
  void setAmbience(String env) => activeAmbience = env;
  double get recommendedGain => activeAmbience == 'BUSY_MARKET' ? 0.15 : 0.05;
}
