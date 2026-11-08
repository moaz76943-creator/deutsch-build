// Sovereign UI Interactive Bridge - Volume 60
class Vol60UIBridge {
  static const int volume = 60;
  static const int startTaskId = 3291;
  static const int endTaskId = 3320;

  static List<int> getTaskIds() => List.generate(30, (i) => startTaskId + i);
  static bool isTaskSupported(int id) => id >= startTaskId && id <= endTaskId;
}
