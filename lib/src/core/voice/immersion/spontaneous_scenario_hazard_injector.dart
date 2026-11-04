/// Task 1185: Injects realistic everyday conversational challenges
class ScenarioHazardInjector {
  String injectHazard(String type) => type == 'NOISE' ? '[Hintergrundgeräusch: Zug fährt ein]' : '[Verkäufer spricht schneller]';
}
