import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/multimodal_dialogue/scene_vqa_engine.dart';

void main() {
  group('SceneVqaEngine Unit Tests (N063)', () {
    final engine = SceneVqaEngine();

    test('Answers "Was siehst du?" with detected objects and spatial prepositions', () {
      engine.updateScene([
        const DetectedVisualObject(
          label: 'cup',
          germanNounWithGender: 'die Kaffeetasse',
          confidence: 0.94,
          spatialRelation: 'auf dem Schreibtisch',
        ),
        const DetectedVisualObject(
          label: 'book',
          germanNounWithGender: 'das Buch',
          confidence: 0.91,
          spatialRelation: 'neben dem Laptop',
        ),
      ]);

      expect(engine.detectedObjectCount, equals(2));

      final reply = engine.answerVisualQuery('Was siehst du hier?');
      expect(reply, contains('die Kaffeetasse (auf dem Schreibtisch)'));
      expect(reply, contains('das Buch (neben dem Laptop)'));
    });

    test('Answers "Wo liegt..." question for specific object', () {
      engine.updateScene([
        const DetectedVisualObject(
          label: 'key',
          germanNounWithGender: 'der Schlüssel',
          confidence: 0.96,
          spatialRelation: 'unter der Zeitung',
        ),
      ]);

      final reply = engine.answerVisualQuery('Wo ist der Schlüssel?');
      expect(reply, contains('der Schlüssel befindet sich unter der Zeitung.'));
    });

    test('Handles empty scene gracefully', () {
      engine.updateScene([]);
      final reply = engine.answerVisualQuery('Was ist das?');
      expect(reply, contains('keine bekannten Gegenstände'));
    });
  });
}
