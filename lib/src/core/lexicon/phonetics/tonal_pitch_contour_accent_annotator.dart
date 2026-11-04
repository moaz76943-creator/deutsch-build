enum TonePitchType { highLevel, rising, dipping, falling }
class TonalPitchContourAccentAnnotator {
  final Map<int, TonePitchType> standardTones = {1: TonePitchType.highLevel, 2: TonePitchType.rising, 3: TonePitchType.dipping, 4: TonePitchType.falling};
}
