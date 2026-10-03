import 'package:deutsch_bilarabi/features/buergeramt_dialogs/application/buergeramt_notifier.dart';
import 'package:deutsch_bilarabi/features/buergeramt_dialogs/data/local_buergeramt_repository.dart';
import 'package:deutsch_bilarabi/features/buergeramt_dialogs/domain/buergeramt_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalBuergeramtRepository', () {
    test('provides Bürgeramt, Bank, and Anmeldung situations', () async {
      final repository = LocalBuergeramtRepository();

      final situations = await repository.getSituations();

      expect(
        situations.map((item) => item.type).toSet(),
        containsAll(<BureaucracySituation>{
          BureaucracySituation.buergeramt,
          BureaucracySituation.bank,
          BureaucracySituation.anmeldung,
        }),
      );
    });

    test('Anmeldung scenario exposes the essential official documents', () async {
      final repository = LocalBuergeramtRepository();

      final situation = (await repository.getSituations()).firstWhere(
        (item) => item.type == BureaucracySituation.anmeldung,
      );

      expect(
        situation.documents.map((item) => item.id),
        containsAll(<String>[
          'passport',
          'anmeldung_form',
          'wohnungsgeberbestaetigung',
        ]),
      );
      expect(
        situation.documents.every((item) => item.labelDe.isNotEmpty),
        isTrue,
      );
    });

    test('checks the appropriate response for an official dialogue turn', () async {
      final repository = LocalBuergeramtRepository();
      final dialogue = await repository.getDialogue('buergeramt_termin');
      final turn = dialogue.firstWhere((item) => item.choices.isNotEmpty);
      final correct = turn.choices.firstWhere((item) => item.isCorrect);
      final wrong = turn.choices.firstWhere((item) => !item.isCorrect);

      expect(
        await repository.checkChoice(
          scenarioId: 'buergeramt_termin',
          turnId: turn.id,
          choiceId: correct.id,
        ),
        isTrue,
      );
      expect(
        await repository.checkChoice(
          scenarioId: 'buergeramt_termin',
          turnId: turn.id,
          choiceId: wrong.id,
        ),
        isFalse,
      );
    });
  });

  group('BuergeramtNotifier', () {
    test('loads a scenario and exposes German-Arabic dialogue flow', () async {
      final notifier = BuergeramtNotifier(LocalBuergeramtRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      await notifier.switchSituation(BureaucracySituation.buergeramt);

      expect(notifier.activeScenario?.id, 'buergeramt_termin');
      expect(notifier.currentTurn, isNotNull);
      expect(notifier.currentTurn!.textDe, isNotEmpty);
      expect(notifier.currentTurn!.translationAr, isNotEmpty);
    });

    test('selecting a response reveals immediate correctness feedback', () async {
      final notifier = BuergeramtNotifier(LocalBuergeramtRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      await notifier.switchSituation(BureaucracySituation.bank);

      while (notifier.currentTurn != null &&
          notifier.currentTurn!.choices.isEmpty) {
        notifier.nextTurn();
      }

      final correct = notifier.currentTurn!.choices.firstWhere(
        (item) => item.isCorrect,
      );
      await notifier.selectResponse(correct.id);

      expect(notifier.selectedChoiceId, correct.id);
      expect(notifier.isCorrect, isTrue);
      expect(notifier.showExplanation, isTrue);
      expect(notifier.feedbackAr, isNotEmpty);
    });

    test('nextTurn clears answer state and advances safely', () async {
      final notifier = BuergeramtNotifier(LocalBuergeramtRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      await notifier.switchSituation(BureaucracySituation.anmeldung);

      while (notifier.currentTurn != null &&
          notifier.currentTurn!.choices.isEmpty) {
        notifier.nextTurn();
      }

      final turnIndex = notifier.currentTurnIndex;
      final correct = notifier.currentTurn!.choices.firstWhere(
        (item) => item.isCorrect,
      );
      await notifier.selectResponse(correct.id);
      notifier.nextTurn();

      expect(notifier.currentTurnIndex, greaterThan(turnIndex));
      expect(notifier.selectedChoiceId, isNull);
      expect(notifier.isCorrect, isNull);
      expect(notifier.showExplanation, isFalse);
    });
  });
}
