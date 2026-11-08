// Sovereign UI Interactive Bridge - Volume 38
class Vol38UIBridge {
  static const int volume = 38;
  static const int startTaskId = 2661;
  static const int endTaskId = 2690;

  static List<int> getTaskIds() => List.generate(30, (i) => startTaskId + i);
  static bool isTaskSupported(int id) => id >= startTaskId && id <= endTaskId;
}
