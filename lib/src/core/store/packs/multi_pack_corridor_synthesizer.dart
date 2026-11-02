class MultiPackCorridorSynthesizer {
  const MultiPackCorridorSynthesizer();
  String buildCorridorKey(String langA, String langB) => '${langA}_to_$langB';
}
