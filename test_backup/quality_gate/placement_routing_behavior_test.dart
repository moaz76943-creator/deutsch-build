import 'package:deutsch_bilarabi/core/curriculum/canonical_curriculum_50.dart';
import 'package:deutsch_bilarabi/features/phase3_integration/life_curriculum_catalog.dart';
import 'package:deutsch_bilarabi/features/placement/domain/placement_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'every placement level has a routable curriculum task at or above its entry point',
    () {
      final routableTaskIds = LifeCurriculumCatalog.standard()
          .links
          .map((link) => link.curriculumTaskId)
          .toSet();

      for (final level in PlacementLevel.values) {
        final routableTasks = CanonicalCurriculum50.tasks.where(
          (task) =>
              task.order >= level.recommendedStartTaskOrder &&
              routableTaskIds.contains(task.id),
        );

        expect(
          routableTasks,
          isNotEmpty,
          reason: '${level.label} must land on at least one openable task.',
        );
      }
    },
  );
}
