/// متتبع جيل الصوت (Audio Generation Tracker)
/// يمنع تضارب وتشغيل مقاطع صوتية متأخرة عند تنقل المستخدم السريع بين البطاقات
class AudioGenerationTracker {
  int _currentGeneration = 0;

  int nextGeneration() {
    _currentGeneration++;
    return _currentGeneration;
  }

  bool isCurrent(int generation) => _currentGeneration == generation;

  void reset() {
    _currentGeneration++;
  }

  int get currentGeneration => _currentGeneration;
}
