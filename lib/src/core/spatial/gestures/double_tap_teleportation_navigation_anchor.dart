/// Task 1657: Double-tap instant teleportation to nearest thematic locus
class TeleportationAnchor {
  String findNearestLocus(double x, double y, List<String> loci) => loci.isNotEmpty ? loci.first : 'ROOT_LOCUS';
}
