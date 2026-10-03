import '../domain/cognitive_load_models.dart';
import '../domain/pacing_repository.dart';

final class LocalPacingRepository implements PacingRepository {
  LocalPacingRepository({this.capacity = 64}) {
    if (capacity < 1 || capacity > 500) {
      throw ArgumentError.value(capacity, 'capacity', 'must be 1..500');
    }
  }

  final int capacity;
  final List<SessionTelemetry> _items = <SessionTelemetry>[];

  @override
  Future<void> record(SessionTelemetry telemetry) async {
    _items.removeWhere((item) => item.eventId == telemetry.eventId);
    _items.add(telemetry);
    _items.sort((a, b) {
      final time = a.occurredAtUtc.compareTo(b.occurredAtUtc);
      return time != 0 ? time : a.eventId.compareTo(b.eventId);
    });
    if (_items.length > capacity) {
      _items.removeRange(0, _items.length - capacity);
    }
  }

  @override
  Future<List<SessionTelemetry>> recent({required int limit}) async {
    final safeLimit = limit.clamp(0, capacity).toInt();
    if (safeLimit == 0 || _items.isEmpty) {
      return const <SessionTelemetry>[];
    }
    final start = (_items.length - safeLimit).clamp(0, _items.length).toInt();
    return List<SessionTelemetry>.unmodifiable(_items.sublist(start));
  }

  @override
  Future<void> clear() async => _items.clear();
}
