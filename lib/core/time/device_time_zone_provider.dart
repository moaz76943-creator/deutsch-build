import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

enum DeviceTimeZoneConfidence {
  exactIdentifier,
  equivalentRules,
}

final class DeviceTimeZoneSnapshot {
  const DeviceTimeZoneSnapshot({
    required this.location,
    required this.locationId,
    required this.nativeName,
    required this.currentOffset,
    required this.capturedAtUtc,
    required this.confidence,
  });

  final tz.Location location;
  final String locationId;
  final String nativeName;
  final Duration currentOffset;
  final DateTime capturedAtUtc;
  final DeviceTimeZoneConfidence confidence;

  bool get exactIdentifier =>
      confidence == DeviceTimeZoneConfidence.exactIdentifier;
}

abstract interface class DeviceTimeZoneProvider {
  Future<DeviceTimeZoneSnapshot> resolve({bool forceRefresh = false});

  Future<DateTime> nowLocal();

  Future<DateTime> toLocal(DateTime instant);

  Future<DateTime> nextLocalOccurrence({
    required int minutesSinceMidnight,
    DateTime? fromUtc,
  });
}

final class SystemDeviceTimeZoneProvider implements DeviceTimeZoneProvider {
  SystemDeviceTimeZoneProvider({
    DateTime Function()? localClock,
  }) : _localClock = localClock ?? DateTime.now;

  final DateTime Function() _localClock;

  DeviceTimeZoneSnapshot? _cached;
  String? _cachedFingerprint;
  bool _databaseInitialized = false;

  @override
  Future<DeviceTimeZoneSnapshot> resolve({
    bool forceRefresh = false,
  }) async {
    _initializeDatabase();
    final nativeNow = _nativeLocalNow();
    final fingerprint =
        '${nativeNow.timeZoneName}|${nativeNow.timeZoneOffset.inMinutes}';

    if (!forceRefresh &&
        _cached != null &&
        _cachedFingerprint == fingerprint) {
      return _cached!;
    }

    final nowUtc = nativeNow.toUtc();
    final samples = _sampleInstants(nowUtc);
    final nativeName = nativeNow.timeZoneName.trim();

    tz.Location? selected;
    var confidence = DeviceTimeZoneConfidence.equivalentRules;

    final direct = tz.timeZoneDatabase.locations[nativeName];
    if (direct != null && _matchesNativeRules(direct, samples)) {
      selected = direct;
      confidence = DeviceTimeZoneConfidence.exactIdentifier;
    }

    selected ??= _bestEquivalentLocation(
      samples: samples,
      nativeName: nativeName,
    );

    if (selected == null) {
      throw StateError('device_timezone_unresolvable');
    }

    tz.setLocalLocation(selected);
    final snapshot = DeviceTimeZoneSnapshot(
      location: selected,
      locationId: selected.name,
      nativeName: nativeName,
      currentOffset: nativeNow.timeZoneOffset,
      capturedAtUtc: nowUtc,
      confidence: confidence,
    );
    _cached = snapshot;
    _cachedFingerprint = fingerprint;
    return snapshot;
  }

  @override
  Future<DateTime> nowLocal() async {
    await resolve();
    return _nativeLocalNow();
  }

  @override
  Future<DateTime> toLocal(DateTime instant) async {
    await resolve();
    return instant.toUtc().toLocal();
  }

  @override
  Future<DateTime> nextLocalOccurrence({
    required int minutesSinceMidnight,
    DateTime? fromUtc,
  }) async {
    if (minutesSinceMidnight < 0 || minutesSinceMidnight >= 24 * 60) {
      throw ArgumentError.value(
        minutesSinceMidnight,
        'minutesSinceMidnight',
        'must be within a local day',
      );
    }
    await resolve();

    final baselineUtc = (fromUtc ?? DateTime.now().toUtc()).toUtc();
    final localNow = baselineUtc.toLocal();
    var candidate = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
      minutesSinceMidnight ~/ 60,
      minutesSinceMidnight % 60,
    );
    if (!candidate.isAfter(localNow)) {
      candidate = DateTime(
        localNow.year,
        localNow.month,
        localNow.day + 1,
        minutesSinceMidnight ~/ 60,
        minutesSinceMidnight % 60,
      );
    }
    return candidate;
  }

  DateTime _nativeLocalNow() {
    final value = _localClock();
    return value.isUtc ? value.toLocal() : value;
  }

  void _initializeDatabase() {
    if (_databaseInitialized) return;
    tz_data.initializeTimeZones();
    _databaseInitialized = true;
  }

  List<DateTime> _sampleInstants(DateTime nowUtc) {
    const offsets = <Duration>[
      Duration(days: -365),
      Duration(days: -180),
      Duration(days: -90),
      Duration.zero,
      Duration(days: 90),
      Duration(days: 180),
      Duration(days: 365),
    ];
    return offsets
        .map((offset) => nowUtc.add(offset))
        .toList(growable: false);
  }

  tz.Location? _bestEquivalentLocation({
    required List<DateTime> samples,
    required String nativeName,
  }) {
    final candidates = <_LocationCandidate>[];
    for (final entry in tz.timeZoneDatabase.locations.entries) {
      final location = entry.value;
      if (!_matchesNativeRules(location, samples)) continue;

      candidates.add(
        _LocationCandidate(
          location: location,
          nativeNameExact:
              entry.key.toLowerCase() == nativeName.toLowerCase(),
        ),
      );
    }

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      if (a.nativeNameExact != b.nativeNameExact) {
        return a.nativeNameExact ? -1 : 1;
      }
      return a.location.name.compareTo(b.location.name);
    });
    return candidates.first.location;
  }

  bool _matchesNativeRules(
    tz.Location location,
    List<DateTime> samples,
  ) {
    for (final instant in samples) {
      final nativeOffset = instant.toLocal().timeZoneOffset;
      final candidateOffset =
          location.timeZone(instant.millisecondsSinceEpoch).offset;
      if (nativeOffset != candidateOffset) return false;
    }
    return true;
  }
}

final class LocalSrsTimePolicy {
  const LocalSrsTimePolicy(this.timeZoneProvider);

  final DeviceTimeZoneProvider timeZoneProvider;

  Future<DateTime> dueAtUtc({
    required DateTime reviewedAt,
    required int intervalDays,
  }) async {
    if (intervalDays < 0 || intervalDays > 3650) {
      throw ArgumentError.value(
        intervalDays,
        'intervalDays',
        'must be between 0 and 3650 days',
      );
    }

    await timeZoneProvider.resolve();
    final reviewedLocal = reviewedAt.toUtc().toLocal();
    if (intervalDays == 0) return reviewedAt.toUtc();

    final dueLocal = DateTime(
      reviewedLocal.year,
      reviewedLocal.month,
      reviewedLocal.day + intervalDays,
      reviewedLocal.hour,
      reviewedLocal.minute,
      reviewedLocal.second,
      reviewedLocal.millisecond,
      reviewedLocal.microsecond,
    );
    return dueLocal.toUtc();
  }

  Future<bool> isDue({
    required DateTime dueAt,
    DateTime? nowUtc,
  }) async {
    await timeZoneProvider.resolve();
    final now = (nowUtc ?? DateTime.now().toUtc()).toUtc().toLocal();
    final due = dueAt.toUtc().toLocal();
    return !due.isAfter(now);
  }
}

final class _LocationCandidate {
  const _LocationCandidate({
    required this.location,
    required this.nativeNameExact,
  });

  final tz.Location location;
  final bool nativeNameExact;
}
