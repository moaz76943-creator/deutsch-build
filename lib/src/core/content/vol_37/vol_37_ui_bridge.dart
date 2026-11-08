// Sovereign UI Interactive Bridge - Volume 37
class Vol37UIBridge {
  static const int volume = 37;
  static const int startTaskId = 2631;
  static const int endTaskId = 2660;

  static List<int> getTaskIds() => List.generate(30, (i) => startTaskId + i);
  static bool isTaskSupported(int id) => id >= startTaskId && id <= endTaskId;
}
