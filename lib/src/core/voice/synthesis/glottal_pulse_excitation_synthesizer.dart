/// Task 1112: Rosenberg glottal pulse excitation source synthesizer
class GlottalPulseSynthesizer {
  double generatePulse(double phase) => phase < 0.6 ? 3.0 * phase * phase - 2.0 * phase * phase * phase : 0.0;
}
