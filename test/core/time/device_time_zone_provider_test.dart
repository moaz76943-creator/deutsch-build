import 'package:deutsch_bilarabi/core/time/device_time_zone_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves host timezone using matching offset units and caches it',
      () async {
    final instant = DateTime.utc(2026, 11, 4, 12);
    final provider = SystemDeviceTimeZoneProvider(localClock: () => instant);

    final snapshot = await provider.resolve();
    expect(snapshot.currentOffset, instant.toLocal().timeZoneOffset);
    expect(
      snapshot.location.timeZone(instant.millisecondsSinceEpoch).offset,
      instant.toLocal().timeZoneOffset.inMilliseconds,
    );
    expect(await provider.resolve(), same(snapshot));
  });

  test('SRS keeps local review time across a daylight saving change', () async {
    final provider = SystemDeviceTimeZoneProvider();
    final reviewed = DateTime(2026, 3, 28, 12, 30);
    final due = await LocalSrsTimePolicy(provider).dueAtUtc(
      reviewedAt: reviewed,
      intervalDays: 1,
    );

    expect(due.toLocal(), DateTime(2026, 3, 29, 12, 30));
  });
}
