import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/ui_v35/phase1/learning_view_models.dart';

void main() {
  group('neutral learning view-model mapping', () {
    test('maps sourceText and targetText without language-shaped field names', () {
      final model = LearningCardViewModel.fromNeutralMap(
        const <String, Object?>{
          'sourceText': 'مرحبا',
          'targetText': 'Hallo',
          'prompt': 'اقرأ ثم أجب',
          'progress': 0.25,
        },
      );

      expect(model.sourceText, 'مرحبا');
      expect(model.targetText, 'Hallo');
      expect(model.prompt, 'اقرأ ثم أجب');
      expect(model.progress, 0.25);
    });

    test('rejects missing neutral source/target coordinates', () {
      expect(
        () => LearningCardViewModel.fromNeutralMap(
          const <String, Object?>{'sourceText': 'مرحبا'},
        ),
        throwsArgumentError,
      );
      expect(
        () => LearningCardViewModel.fromNeutralMap(
          const <String, Object?>{'targetText': 'Hallo'},
        ),
        throwsArgumentError,
      );
    });
  });
}
