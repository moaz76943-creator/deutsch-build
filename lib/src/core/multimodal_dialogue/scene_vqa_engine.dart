/// A detected object in the physical camera view with spatial metadata.
class DetectedVisualObject {
  final String label; // e.g. 'cup', 'table', 'book'
  final String germanNounWithGender; // e.g. 'die Tasse', 'der Tisch'
  final double confidence;
  final String spatialRelation; // 'auf dem Tisch', 'neben dem Buch'

  const DetectedVisualObject({
    required this.label,
    required this.germanNounWithGender,
    required this.confidence,
    required this.spatialRelation,
  });
}

/// Offline visual question answering engine linking physical camera surroundings to target language learning.
class SceneVqaEngine {
  final List<DetectedVisualObject> _detectedScene = [];

  void updateScene(List<DetectedVisualObject> objects) {
    _detectedScene.clear();
    _detectedScene.addAll(objects);
  }

  int get detectedObjectCount => _detectedScene.length;

  /// Answers learner questions about their immediate physical surroundings in German.
  String answerVisualQuery(String query) {
    final lower = query.toLowerCase();

    if (_detectedScene.isEmpty) {
      return 'Ich sehe im Moment keine bekannten Gegenstände in der Kamera.';
    }

    if (lower.contains('was ist') || lower.contains('was liegt') || lower.contains('was siehst')) {
      final descriptions = _detectedScene.map((o) => '${o.germanNounWithGender} (${o.spatialRelation})').join(', ');
      return 'Ich sehe: $descriptions.';
    }

    if (lower.contains('wo ist') || lower.contains('wo liegt')) {
      for (final obj in _detectedScene) {
        if (lower.contains(obj.label) || lower.contains(obj.germanNounWithGender.toLowerCase())) {
          return '${obj.germanNounWithGender} befindet sich ${obj.spatialRelation}.';
        }
      }
    }

    return 'Auf dem Bild sehe ich ${_detectedScene.first.germanNounWithGender}.';
  }
}
