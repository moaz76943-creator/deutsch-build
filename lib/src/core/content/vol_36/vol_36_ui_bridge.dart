// Sovereign UI Interactive Bridge - Volume 36
class Vol36UIBridge {
  static const int volume = 36;
  static const int startTaskId = 2601;
  static const int endTaskId = 2630;

  static List<int> getTaskIds() => List.generate(30, (i) => startTaskId + i);
  static bool isTaskSupported(int id) => id >= startTaskId && id <= endTaskId;
}
