// Sovereign UI Interactive Bridge - Volume 62
class Vol62UIBridge {
  static const int volume = 62;
  static const int startTaskId = 3351;
  static const int endTaskId = 3380;

  static List<int> getTaskIds() => List.generate(30, (i) => startTaskId + i);
  static bool isTaskSupported(int id) => id >= startTaskId && id <= endTaskId;
}
