/// حارس التوقيت الرتيب وكشف التلاعب بساعة النظام - Study 24
/// يمنع المتعلم من تقديم أو تأخير ساعة الهاتف لتخطي مواعيد المراجعة الذكية أو التلاعب بالسلسلة (Streaks)
class MonotonicClockGuard {
  final Stopwatch _stopwatch = Stopwatch();
  DateTime? _anchoredWallTimeUtc;
  DateTime? _lastPersistedTimestampUtc;

  MonotonicClockGuard({DateTime? lastPersistedTimestamp}) {
    _lastPersistedTimestampUtc = lastPersistedTimestamp?.toUtc();
    _stopwatch.start();
    _anchoredWallTimeUtc = DateTime.now().toUtc();
  }

  /// إعادة ضبط وتثبيت المرجع التوقيتي
  void anchor({required DateTime wallTimeUtc, DateTime? persistedTimestampUtc}) {
    _anchoredWallTimeUtc = wallTimeUtc.toUtc();
    _lastPersistedTimestampUtc = persistedTimestampUtc?.toUtc() ?? _lastPersistedTimestampUtc;
    _stopwatch.reset();
    _stopwatch.start();
  }

  /// الحصول على التوقيت الفعلي المعتمد والمحمي من التلاعب الرجعي
  DateTime getEffectiveUtcTime([DateTime? currentWallTime]) {
    final nowWall = (currentWallTime ?? DateTime.now()).toUtc();
    final elapsed = _stopwatch.elapsed;
    final monotonicProjected = _anchoredWallTimeUtc?.add(elapsed) ?? nowWall;

    // فحص التلاعب بالرجوع للماضي (Clock turned backwards)
    if (_lastPersistedTimestampUtc != null && nowWall.isBefore(_lastPersistedTimestampUtc!)) {
      // حظر العودة للماضي واعتماد التوقيت المحفوظ مضافاً إليه الوقت الرتيب المنقضي
      return _lastPersistedTimestampUtc!.add(elapsed);
    }

    // إذا كانت ساعة الحائط متأخرة عن الوقت الرتيب المتوقع منذ فتح التطبيق
    if (_anchoredWallTimeUtc != null && nowWall.isBefore(_anchoredWallTimeUtc!)) {
      return monotonicProjected;
    }

    return nowWall;
  }

  /// كشف ما إذا كان هناك تلاعب رجعي مؤكد بساعة النظام
  bool isBackwardsTimeTampered([DateTime? currentWallTime]) {
    final now = (currentWallTime ?? DateTime.now()).toUtc();
    if (_lastPersistedTimestampUtc != null && now.isBefore(_lastPersistedTimestampUtc!)) {
      return true;
    }
    if (_anchoredWallTimeUtc != null && now.isBefore(_anchoredWallTimeUtc!)) {
      return true;
    }
    return false;
  }

  /// كشف القفزات الكبيرة المشبوهة للأمام (أكثر من 365 يوماً دفعة واحدة)
  bool isForwardAnomaly([DateTime? currentWallTime]) {
    final now = (currentWallTime ?? DateTime.now()).toUtc();
    final anchor = _lastPersistedTimestampUtc ?? _anchoredWallTimeUtc;
    if (anchor == null) return false;

    final difference = now.difference(anchor);
    return difference.inDays > 365;
  }

  /// تحديث آخر توقيت حدث معتمد ومحفوظ في قاعدة البيانات
  void updatePersistedCheckpoint(DateTime eventTimestampUtc) {
    final utc = eventTimestampUtc.toUtc();
    if (_lastPersistedTimestampUtc == null || utc.isAfter(_lastPersistedTimestampUtc!)) {
      _lastPersistedTimestampUtc = utc;
    }
  }
}
