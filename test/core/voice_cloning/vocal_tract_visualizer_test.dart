import 'package:test/test.dart';
import '../../lib/src/core/voice_cloning/vocal_tract_visualizer.dart';

void main() {
  test('N003: VocalTractVisualizer maps formants', () {
    final vis = VocalTractVisualizer();
    final geom = vis.mapFormantsToTract(f1: 300, f2: 2200);
    expect(geom.tongueHeight, greaterThan(0.6));
  });
}
