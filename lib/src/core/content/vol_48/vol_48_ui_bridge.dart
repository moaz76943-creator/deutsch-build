// Sovereign UI Interactive Bridge - Volume 48
class Vol48UIBridge {
  static const int volume = 48;
  static const int startTaskId = 2961;
  static const int endTaskId = 2990;

  static List<int> getTaskIds() => List.generate(30, (i) => startTaskId + i);
  static bool isTaskSupported(int id) => id >= startTaskId && id <= endTaskId;
}
