/// Task 1827: Directional event filter ensuring events only reach relevant language corridors
class CorridorEventRoutingFilter {
  bool matchesCorridor(String targetCorridor, String activeCorridor) => targetCorridor == activeCorridor;
}
