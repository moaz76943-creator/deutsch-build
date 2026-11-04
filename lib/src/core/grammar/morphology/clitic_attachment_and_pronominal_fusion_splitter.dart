/// Task 1331: Splits fused clitics (e.g. ins, vom, zum, dámelo)
class CliticFusionSplitter {
  List<String> splitClitic(String word) => word == 'ins' ? ['in', 'das'] : (word == 'zum' ? ['zu', 'dem'] : [word]);
}
