import 'package:test/test.dart';
import 'package:deutsch_build/src/core/voice_cloning/vocal_tract_3d_visualizer.dart';

void main() {
  group('VocalTract3dVisualizer Tests', () {
    const visualizer = VocalTract3dVisualizer();

    test('Contrasts tongue dorsum placement between ich-Laut and ach-Laut accurately', () {
      final ichLaut = visualizer.getPose('ç');
      final achLaut = visualizer.getPose('x');

      // ich-Laut is front/palatal (higher x), ach-Laut is retracted velar (negative x)
      expect(ichLaut.tongueDorsum.x, greaterThan(achLaut.tongueDorsum.x));
      expect(ichLaut.vocalCordsVibrating, isFalse);
    });

    test('German ü pose reflects tight lip protrusion rounding ratio', () {
      final uePose = visualizer.getPose('y');

      expect(uePose.lipRoundingRatio, greaterThan(0.9));
      expect(uePose.vocalCordsVibrating, isTrue);
    });

    test('Smoothly interpolates 3D coordinates between poses for Canvas 60fps rendering', () {
      final poseA = visualizer.getPose('ç');
      final poseB = visualizer.getPose('x');

      final midPose = visualizer.interpolatePoses(poseA, poseB, 0.5);

      expect(midPose.tongueDorsum.x, equals((poseA.tongueDorsum.x + poseB.tongueDorsum.x) / 2.0));
      expect(midPose.tongueDorsum.y, equals((poseA.tongueDorsum.y + poseB.tongueDorsum.y) / 2.0));
    });
  });
}
