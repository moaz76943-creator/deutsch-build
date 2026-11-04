/// Task 1213: Cyrillic extended accent mark and iotated vowel shaping
class CyrillicDiacriticsEngine {
  bool isCyrillic(int code) => code >= 0x0400 && code <= 0x04FF;
}
