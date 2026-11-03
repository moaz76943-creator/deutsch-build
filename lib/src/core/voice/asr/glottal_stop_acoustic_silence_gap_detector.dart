/// Task 1154: Acoustic silence gap detector for glottal stop /ʔ/
class GlottalStopDetector {
  bool isGlottalStop(int gapMs, double burstDb) => gapMs >= 20 && gapMs <= 80 && burstDb > -20.0;
}
