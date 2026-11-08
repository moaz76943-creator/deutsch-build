// Sovereign UI Interactive Bridge - Volume 46
class Vol46UIBridge {
  static const int volume = 46;
  static const int startTaskId = 2901;
  static const int endTaskId = 2930;

  static List<int> getTaskIds() => List.generate(30, (i) => startTaskId + i);
  static bool isTaskSupported(int id) => id >= startTaskId && id <= endTaskId;
}
