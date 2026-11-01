class DynamicRangeCompanderAgc {
  final double targetRms;
  const DynamicRangeCompanderAgc({this.targetRms = 0.2});
  List<double> processAgc(List<double> signal) => List.from(signal);
}
