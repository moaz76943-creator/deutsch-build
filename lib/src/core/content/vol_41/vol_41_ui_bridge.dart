// Sovereign UI Interactive Bridge - Volume 41
class Vol41UIBridge {
  static const int volume = 41;
  static const int startTaskId = 2751;
  static const int endTaskId = 2780;

  static List<int> getTaskIds() => List.generate(30, (i) => startTaskId + i);
  static bool isTaskSupported(int id) => id >= startTaskId && id <= endTaskId;
}
