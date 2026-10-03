import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/separable_verbs/application/separable_verbs_notifier.dart';
import 'package:deutsch_bilarabi/features/separable_verbs/data/local_separable_verbs_repository.dart';
import 'package:deutsch_bilarabi/features/separable_verbs/domain/separable_verbs_models.dart';

void main() {
  test('question bank classifies major prefix families correctly', () async {
    final repository = LocalSeparableVerbsRepository();
    final drills = await repository.getDrills();

    final separablePrefixes = drills
        .where((item) => item.prefixType == PrefixType.separable)
        .map((item) => item.prefix)
        .toSet();
    final inseparablePrefixes = drills
        .where((item) => item.prefixType == PrefixType.inseparable)
        .map((item) => item.prefix)
        .toSet();
    final dualPrefixes = drills
        .where((item) => item.prefixType == PrefixType.dualVariable)
        .map((item) => item.prefix)
        .toSet();

    expect(
      separablePrefixes,
      containsAll(<String>{'an', 'auf', 'aus', 'ein', 'mit', 'vor', 'zu'}),
    );
    expect(
      inseparablePrefixes,
      containsAll(<String>{
        'be',
        'emp',
        'ent',
        'er',
        'ge',
        'miss',
        'ver',
        'zer',
      }),
    );
    expect(
      dualPrefixes,
      containsAll(<String>{'über', 'unter', 'um', 'durch'}),
    );
  });

  test('repository validates prefix placement and conjugation together', () async {
    final repository = LocalSeparableVerbsRepository();
    final drills = await repository.getDrills();

    final aufstehen =
        drills.firstWhere((item) => item.fullInfinitive == 'aufstehen');
    expect(
      await repository.validateAnswer(
        drillId: aufstehen.id,
        selectedPlacement: PrefixPlacement.sentenceEndDetached,
        conjugatedVerb: 'stehe',
      ),
      isTrue,
    );
    expect(
      await repository.validateAnswer(
        drillId: aufstehen.id,
        selectedPlacement: PrefixPlacement.position2Attached,
        conjugatedVerb: 'stehe',
      ),
      isFalse,
    );

    final verstehen =
        drills.firstWhere((item) => item.fullInfinitive == 'verstehen');
    expect(
      await repository.validateAnswer(
        drillId: verstehen.id,
        selectedPlacement: PrefixPlacement.position2Attached,
        conjugatedVerb: 'verstehe',
      ),
      isTrue,
    );
    expect(
      await repository.validateAnswer(
        drillId: verstehen.id,
        selectedPlacement: PrefixPlacement.sentenceEndDetached,
        conjugatedVerb: 'stehe',
      ),
      isFalse,
    );
  });

  test('dual-variable prefix is evaluated by the active meaning', () async {
    final repository = LocalSeparableVerbsRepository();
    final drills = await repository.getDrills();

    final translate = drills.firstWhere(
      (item) => item.id == 'dual_ueber_translate',
    );
    final ferryAcross = drills.firstWhere(
      (item) => item.id == 'dual_ueber_cross',
    );

    expect(translate.prefixType, PrefixType.dualVariable);
    expect(translate.expectedPlacement, PrefixPlacement.position2Attached);
    expect(ferryAcross.prefixType, PrefixType.dualVariable);
    expect(
      ferryAcross.expectedPlacement,
      PrefixPlacement.sentenceEndDetached,
    );
  });

  test('notifier filters, verifies, explains and advances drills', () async {
    final notifier = SeparableVerbsNotifier(
      LocalSeparableVerbsRepository(),
    );
    addTearDown(notifier.dispose);

    await notifier.initialize();
    await notifier.filterByType(PrefixType.separable);

    expect(notifier.currentVerb, isNotNull);
    expect(notifier.currentVerb!.prefixType, PrefixType.separable);

    final current = notifier.currentVerb!;
    await notifier.checkPrefixPlacement(
      current.expectedPlacement,
      conjugatedVerb: current.expectedConjugatedVerb,
    );

    expect(notifier.isCorrect, isTrue);
    expect(notifier.explanation, contains(current.prefix));

    final firstId = current.id;
    notifier.nextDrill();
    expect(notifier.currentVerb, isNotNull);
    expect(notifier.currentVerb!.id, isNot(firstId));
    expect(notifier.selectedPlacement, isNull);
    expect(notifier.isCorrect, isNull);
  });
}
