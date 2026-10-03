import 'package:deutsch_bilarabi/features/passiv_arena/application/passiv_notifier.dart';
import 'package:deutsch_bilarabi/features/passiv_arena/data/local_passiv_repository.dart';
import 'package:deutsch_bilarabi/features/passiv_arena/domain/passiv_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalPassivRepository', () {
    test('moves Akkusativ object to Nominativ in Vorgangspassiv', () async {
      final repository = LocalPassivRepository();

      final drills = await repository.getDrills(type: PassivType.vorgangspassiv);
      final drill = drills.firstWhere(
        (item) => item.id == 'vorgang_praesens_person',
      );

      expect(drill.akkusativObject, 'den Motor');
      expect(drill.nominativSubject, 'der Motor');
      expect(drill.auxiliaryForm, 'wird');
      expect(drill.partizipII, 'repariert');
      expect(drill.agentPreposition, 'von');
      expect(
        drill.passiveSentence,
        'Der Motor wird von dem Mechaniker repariert.',
      );
    });

    test('uses durch + Akkusativ for an instrument or means', () async {
      final repository = LocalPassivRepository();

      final drills = await repository.getDrills(type: PassivType.vorgangspassiv);
      final drill = drills.firstWhere(
        (item) => item.id == 'vorgang_praesens_instrument',
      );

      expect(drill.originalAgent, 'die Maschine');
      expect(drill.agentPreposition, 'durch');
      expect(drill.agentCaseLabel, 'Akkusativ');
      expect(drill.passiveSentence, contains('durch die Maschine'));
    });

    test('distinguishes werden event passive from sein state passive', () async {
      final repository = LocalPassivRepository();

      final eventDrill = (await repository.getDrills(
        type: PassivType.vorgangspassiv,
      )).firstWhere((item) => item.id == 'vorgang_praesens_person');
      final stateDrill = (await repository.getDrills(
        type: PassivType.zustandspassiv,
      )).firstWhere((item) => item.id == 'zustand_praesens_window');

      expect(eventDrill.auxiliaryForm, 'wird');
      expect(eventDrill.partizipII, 'repariert');
      expect(stateDrill.auxiliaryForm, 'ist');
      expect(stateDrill.partizipII, 'geöffnet');
      expect(stateDrill.passiveSentence, 'Das Fenster ist geöffnet.');
    });

    test('covers Präteritum and Perfekt passive structures', () async {
      final repository = LocalPassivRepository();
      final drills = await repository.getDrills();

      final eventPast = drills.firstWhere(
        (item) => item.id == 'vorgang_praeteritum_package',
      );
      final eventPerfect = drills.firstWhere(
        (item) => item.id == 'vorgang_perfekt_report',
      );
      final statePast = drills.firstWhere(
        (item) => item.id == 'zustand_praeteritum_door',
      );
      final statePerfect = drills.firstWhere(
        (item) => item.id == 'zustand_perfekt_room',
      );

      expect(eventPast.auxiliaryForm, 'wurde');
      expect(eventPerfect.passiveSentence, contains('worden'));
      expect(statePast.auxiliaryForm, 'war');
      expect(statePerfect.passiveSentence, contains('gewesen'));
    });

    test('checks normalized auxiliary, preposition and participle', () async {
      final repository = LocalPassivRepository();

      expect(
        await repository.checkTransformation(
          drillId: 'vorgang_praesens_person',
          auxiliaryForm: ' wird ',
          agentPreposition: 'VON',
          partizipII: 'repariert',
        ),
        isTrue,
      );
      expect(
        await repository.checkTransformation(
          drillId: 'vorgang_praesens_person',
          auxiliaryForm: 'ist',
          agentPreposition: 'von',
          partizipII: 'repariert',
        ),
        isFalse,
      );
    });
  });

  group('PassivNotifier', () {
    test('checks transformation and reveals immediate explanation', () async {
      final notifier = PassivNotifier(LocalPassivRepository());
      addTearDown(notifier.dispose);

      await notifier.load(type: PassivType.vorgangspassiv);
      final drill = notifier.currentDrill!;

      await notifier.checkTransformation(
        auxiliaryForm: drill.auxiliaryForm,
        agentPreposition: drill.agentPreposition,
        partizipII: drill.partizipII,
      );

      expect(notifier.selectedAuxiliary, drill.auxiliaryForm);
      expect(notifier.selectedPreposition, drill.agentPreposition);
      expect(notifier.selectedPartizipII, drill.partizipII);
      expect(notifier.isCorrect, isTrue);
      expect(notifier.showExplanation, isTrue);
    });

    test('nextDrill clears answer state and advances', () async {
      final notifier = PassivNotifier(LocalPassivRepository());
      addTearDown(notifier.dispose);

      await notifier.load(type: PassivType.vorgangspassiv);
      final firstId = notifier.currentDrill!.id;
      final drill = notifier.currentDrill!;
      await notifier.checkTransformation(
        auxiliaryForm: drill.auxiliaryForm,
        agentPreposition: drill.agentPreposition,
        partizipII: drill.partizipII,
      );

      notifier.nextDrill();

      expect(notifier.currentIndex, 1);
      expect(notifier.currentDrill!.id, isNot(firstId));
      expect(notifier.selectedAuxiliary, isNull);
      expect(notifier.selectedPreposition, isNull);
      expect(notifier.selectedPartizipII, isNull);
      expect(notifier.isCorrect, isNull);
      expect(notifier.showExplanation, isFalse);
    });

    test('switchPassivType reloads only requested passive type', () async {
      final notifier = PassivNotifier(LocalPassivRepository());
      addTearDown(notifier.dispose);

      await notifier.load(type: PassivType.vorgangspassiv);
      await notifier.switchPassivType(PassivType.zustandspassiv);

      expect(notifier.activeType, PassivType.zustandspassiv);
      expect(notifier.currentIndex, 0);
      expect(
        notifier.drills.every(
          (item) => item.type == PassivType.zustandspassiv,
        ),
        isTrue,
      );
      expect(notifier.showExplanation, isFalse);
    });
  });
}
