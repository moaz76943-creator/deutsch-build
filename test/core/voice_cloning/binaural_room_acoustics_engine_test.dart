import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/voice_cloning/binaural_room_acoustics_engine.dart';

void main() {
  group('BinauralRoomAcousticsEngine Tests', () {
    const engine = BinauralRoomAcousticsEngine();

    test('Renders binaural stereo pair with accurate azimuth spatial panning', () {
      final mono = Int16List.fromList(List.generate(1000, (i) => 5000));
      const leftPanConfig = SpatialAudioConfig(
        environment: AmbientSpaceEnvironment.vibrantBerlinCafe,
        azimuthDegrees: -60.0, // Positioned strongly to the left
      );

      final stereo = engine.renderBinauralStereoPair(mono, leftPanConfig);

      expect(stereo['left']!.length, equals(1000));
      expect(stereo['right']!.length, equals(1000));
      // Left channel energy should strictly exceed right channel energy
      expect(stereo['left']![100], greaterThan(stereo['right']![100]));
    });

    test('Center pan renders balanced stereo symmetry', () {
      final mono = Int16List.fromList([3000, 4000, 5000]);
      const centerConfig = SpatialAudioConfig(
        environment: AmbientSpaceEnvironment.cozyLivingRoom,
        azimuthDegrees: 0.0,
      );

      final stereo = engine.renderBinauralStereoPair(mono, centerConfig);
      expect(stereo['left']![0], equals(stereo['right']![0]));
    });
  });
}
