class NasalResonanceDetector {
  bool isNasalized({required double nasalEnergy, required double oralEnergy}) {
    if (oralEnergy <= 0) return nasalEnergy > 0;
    return (nasalEnergy / oralEnergy) > 0.45;
  }
}
