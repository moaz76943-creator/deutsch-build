import 'package:deutsch_bilarabi/features/comparative_superlative/application/comparison_notifier.dart';
import 'package:deutsch_bilarabi/features/comparative_superlative/data/local_comparison_repository.dart';
import 'package:deutsch_bilarabi/features/comparative_superlative/domain/comparison_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalComparisonRepository', () {
    test('validates regular, umlaut, and irregular comparison forms', () async {
      final repository = LocalComparisonRepository();
      final challenges = await repository.getChallenges();

      ComparisonChallengeItem byId(String id) =>
          challenges.firstWhere((item) => item.id == id);

      expect(byId('regular_schnell').komparativ, 'schneller');
      expect(byId('regular_schnell').superlativ, 'am schnellsten');
      expect(byId('umlaut_gross').komparativ, 'größer');
      expect(byId('umlaut_gross').superlativ, 'am größten');
      expect(byId('irregular_gut').komparativ, 'besser');
      expect(byId('irregular_gut').superlativ, 'am besten');

      expect(
        await repository.checkForm(
          'umlaut_gross',
          ComparisonDegree.komparativ,
          ' größer ',
        ),
        isTrue,
      );
      expect(
        await repository.checkForm(
          'irregular_gut',
          ComparisonDegree.superlativ,
          'am besten',
        ),
        isTrue,
      );
      expect(
        await repository.checkForm(
          'regular_schnell',
          ComparisonDegree.komparativ,
          'schnellste',
        ),
        isFalse,
      );
    });

    test('distinguishes wie for equality from als for comparison', () async {
      final repository = LocalComparisonRepository();

      expect(
        await repository.checkConnector(
          'regular_schnell',
          ComparisonDegree.positiv,
          'wie',
        ),
        isTrue,
      );
      expect(
        await repository.checkConnector(
          'regular_schnell',
          ComparisonDegree.positiv,
          'als',
        ),
        isFalse,
      );
      expect(
        await repository.checkConnector(
          'regular_schnell',
          ComparisonDegree.komparativ,
          'als',
        ),
        isTrue,
      );
      expect(
        await repository.checkConnector(
          'regular_schnell',
          ComparisonDegree.komparativ,
          'wie',
        ),
        isFalse,
      );
    });

    test('filters the local bank by rule type', () async {
      final repository = LocalComparisonRepository();

      final umlaut = await repository.getChallenges(
        ruleType: ComparisonRuleType.umlautChange,
      );
      final irregular = await repository.getChallenges(
        ruleType: ComparisonRuleType.irregular,
      );

      expect(umlaut, isNotEmpty);
      expect(
        umlaut.every(
          (item) => item.ruleType == ComparisonRuleType.umlautChange,
        ),
        isTrue,
      );
      expect(irregular, isNotEmpty);
      expect(
        irregular.every(
          (item) => item.ruleType == ComparisonRuleType.irregular,
        ),
        isTrue,
      );
    });
  });

  group('ComparisonNotifier', () {
    test('checks answer and connector then reveals explanation', () async {
      final notifier = ComparisonNotifier(LocalComparisonRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      notifier.setTargetDegree(ComparisonDegree.komparativ);
      final challenge = notifier.currentChallenge!;

      await notifier.checkComparisonAnswer(
        form: challenge.komparativ,
        connector: 'als',
      );

      expect(notifier.selectedAnswer, challenge.komparativ);
      expect(notifier.selectedConnector, 'als');
      expect(notifier.isCorrect, isTrue);
      expect(notifier.showExplanation, isTrue);
    });

    test('nextChallenge clears answer state', () async {
      final notifier = ComparisonNotifier(LocalComparisonRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      final firstId = notifier.currentChallenge!.id;
      notifier.setTargetDegree(ComparisonDegree.komparativ);
      await notifier.checkComparisonAnswer(
        form: notifier.currentChallenge!.komparativ,
        connector: 'als',
      );

      notifier.nextChallenge();

      expect(notifier.currentChallenge, isNotNull);
      expect(notifier.currentChallenge!.id, isNot(firstId));
      expect(notifier.selectedAnswer, isNull);
      expect(notifier.selectedConnector, isNull);
      expect(notifier.isCorrect, isNull);
      expect(notifier.showExplanation, isFalse);
    });

    test('filterByRuleType resets to a matching challenge', () async {
      final notifier = ComparisonNotifier(LocalComparisonRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      await notifier.filterByRuleType(ComparisonRuleType.irregular);

      expect(notifier.activeRuleType, ComparisonRuleType.irregular);
      expect(notifier.currentChallenge, isNotNull);
      expect(
        notifier.challenges.every(
          (item) => item.ruleType == ComparisonRuleType.irregular,
        ),
        isTrue,
      );
      expect(notifier.currentIndex, 0);
    });
  });
}
