// Sovereign UI Interactive Bridge - Volume 40
class Vol40UIBridge {
  static const int volume = 40;
  static const int startTaskId = 2721;
  static const int endTaskId = 2750;

  static List<int> getTaskIds() => List.generate(30, (i) => startTaskId + i);
  static bool isTaskSupported(int id) => id >= startTaskId && id <= endTaskId;
}
