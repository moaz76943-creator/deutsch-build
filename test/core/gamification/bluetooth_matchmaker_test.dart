import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/gamification/bluetooth_matchmaker.dart';

void main() {
  test('Selects strongest signal peer for low latency duel', () {
    final mm = BluetoothMatchmaker();
    mm.registerDiscoveredPeer(const BlePeerLearner(peerId: '1', displayName: 'P1', rssiSignalStrength: -75, levelRank: 5));
    mm.registerDiscoveredPeer(const BlePeerLearner(peerId: '2', displayName: 'P2', rssiSignalStrength: -45, levelRank: 6));
    final best = mm.selectOptimalDuelOpponent();
    expect(best!.peerId, equals('2'));
  });
}
