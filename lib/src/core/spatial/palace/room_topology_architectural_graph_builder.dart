/// Task 1602: Procedural architectural room graph connecting halls and corridors
class RoomTopologyGraphBuilder {
  final Map<String, List<String>> _rooms = {};
  void connectRooms(String r1, String r2) => _rooms.putIfAbsent(r1, () => []).add(r2);
}
