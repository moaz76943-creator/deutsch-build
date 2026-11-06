import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/quality/production_acceptance_gate.dart';

void main() {
  group('ProductionAcceptanceGate - Compatibility', () {
    test('verifyAppReadiness works as before', () {
      final ready = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: true,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      expect(ready, isTrue);

      final notReady = ProductionAcceptanceGate.verifyAppReadiness(
        isOfflineSafe: false,
        isStorageGuarded: true,
        isLifecycleManaged: true,
      );
      expect(notReady, isFalse);
    });
  });

}
