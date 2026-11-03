class CefrC1ModuleTimingAdaptiveEvaluator {
  bool isPassing(int reading, int listening, int writing, int speaking) =>
      (reading + listening + writing + speaking) >= 60;
}
