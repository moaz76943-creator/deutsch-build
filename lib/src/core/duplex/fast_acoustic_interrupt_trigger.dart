class FastAcousticInterruptTrigger {
  final double energyThreshold;
  const FastAcousticInterruptTrigger({this.energyThreshold = 0.3});
  bool shouldInterrupt(double energy) => energy >= energyThreshold;
}
