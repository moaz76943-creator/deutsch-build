import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/release/final_release_quality_gate.dart';

void main() {
  test('All five sovereign subsystem pillars report 100% healthy', () {
    const gate = FinalReleaseQualityGate();
    expect(gate.isProductionReady(), isTrue);
  });
}
