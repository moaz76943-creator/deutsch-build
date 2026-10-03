import 'package:deutsch_bilarabi/features/prepositions_arena/data/local_prepositions_repository.dart';
import 'package:deutsch_bilarabi/features/prepositions_arena/domain/preposition_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = LocalPrepositionsRepository();

  test('bank contains common A1/A2 Akkusativ, Dativ and two-way groups', () {
    final items = repository.allPrepositions();

    expect(
      items.where((item) => item.type == PrepositionType.accusative),
      isNotEmpty,
    );
    expect(
      items.where((item) => item.type == PrepositionType.dative),
      isNotEmpty,
    );
    expect(
      items.where((item) => item.type == PrepositionType.twoWay),
      isNotEmpty,
    );
    expect(items.map((item) => item.preposition), containsAll(<String>[
      'für',
      'mit',
      'in',
      'auf',
      'an',
    ]));
    expect(items.every((item) => item.level == 'A1' || item.level == 'A2'), isTrue);
  });

  test('two-way challenge bank contains both Wohin and Wo contexts', () {
    final challenges = repository.challenges(
      type: PrepositionType.twoWay,
    );

    expect(
      challenges.any((item) => item.spatialQuestion == SpatialQuestion.wohin),
      isTrue,
    );
    expect(
      challenges.any((item) => item.spatialQuestion == SpatialQuestion.wo),
      isTrue,
    );
  });

  test('repository ids resolve to canonical preposition entries', () {
    final item = repository.byId('mit');

    expect(item?.preposition, 'mit');
    expect(item?.type, PrepositionType.dative);
  });
}
