import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/berufssprache/application/berufssprache_notifier.dart';
import 'package:deutsch_bilarabi/features/berufssprache/data/local_berufssprache_repository.dart';
import 'package:deutsch_bilarabi/features/berufssprache/domain/berufssprache_models.dart';
import 'package:deutsch_bilarabi/features/berufssprache/presentation/berufssprache_screen.dart';

void main() {
  const repository = LocalBerufsspracheRepository();

  group('LocalBerufsspracheRepository', () {
    test('covers every required workplace communication topic', () async {
      final all = await repository.getPhrases();

      expect(all, hasLength(20));
      for (final topic in WorkplaceTopic.values) {
        final topicPhrases = all.where((item) => item.topic == topic).toList();
        expect(topicPhrases, hasLength(4));
      }
    });

    test('contains professional examples for the requested hub scenarios',
        () async {
      final all = await repository.getPhrases();
      final german = all.map((item) => item.german).join(' ');

      expect(german, contains('Protokoll'));
      expect(german, contains('Termin'));
      expect(german, contains('Verantwortung'));
      expect(german, contains('Könnten Sie'));
      expect(german, contains('Anruf'));
    });

    test('keeps the phrase bank wholesome and workplace-focused', () async {
      final all = await repository.getPhrases();
      final combined = all
          .expand((item) => <String>[
                item.german,
                item.arabic,
                item.usageArabic,
              ])
          .join(' ')
          .toLowerCase();

      for (final blocked in <String>[
        'alkohol',
        'bier',
        'wein',
        'musik',
        'nachtclub',
        'party',
      ]) {
        expect(combined, isNot(contains(blocked)));
      }
    });

    test('validates German phrases while ignoring punctuation and spacing',
        () async {
      expect(
        await repository.validateGermanPhrase(
          'schedule_confirm',
          '  Dann bestätige ich den Termin für Donnerstag um 14 Uhr  ',
        ),
        isTrue,
      );
      expect(
        await repository.validateGermanPhrase(
          'schedule_confirm',
          'Dann bestätige ich den Termin für Freitag um 14 Uhr.',
        ),
        isFalse,
      );
    });
  });

  group('ProtocolDraft', () {
    test('renders a structured German meeting protocol with delegated tasks', () {
      const draft = ProtocolDraft(
        date: '12.10.2026',
        participants: <String>['Frau Keller', 'Herr Berger'],
        discussionPoints: <String>['Zeitplan prüfen'],
        decisions: <String>['Termin am Donnerstag bestätigen'],
        tasks: <ProtocolTask>[
          ProtocolTask(
            task: 'Unterlagen vorbereiten',
            responsible: 'Frau Keller',
            deadline: 'Mittwoch',
          ),
        ],
      );

      final text = draft.renderGerman();

      expect(text, contains('Protokoll'));
      expect(text, contains('Teilnehmende: Frau Keller, Herr Berger'));
      expect(text, contains('Beschlüsse:'));
      expect(text, contains('Zuständig: Frau Keller'));
      expect(text, contains('Frist: Mittwoch'));
    });

    test('rejects a protocol without a date or participants', () {
      expect(
        () => const ProtocolDraft(
          date: ' ',
          participants: <String>['Frau Keller'],
          discussionPoints: <String>[],
          decisions: <String>[],
          tasks: <ProtocolTask>[],
        ).renderGerman(),
        throwsArgumentError,
      );
      expect(
        () => const ProtocolDraft(
          date: '12.10.2026',
          participants: <String>[],
          discussionPoints: <String>[],
          decisions: <String>[],
          tasks: <ProtocolTask>[],
        ).renderGerman(),
        throwsArgumentError,
      );
    });
  });

  group('BerufsspracheNotifier', () {
    test('loads deterministic content and filters by workplace topic', () async {
      final notifier = BerufsspracheNotifier(repository: repository);
      addTearDown(notifier.dispose);

      await notifier.load();
      expect(notifier.currentPhrase?.id, 'minutes_take_notes');

      await notifier.filterByTopic(WorkplaceTopic.formalTelephone);
      expect(notifier.phrases, hasLength(4));
      expect(
        notifier.phrases.every(
          (item) => item.topic == WorkplaceTopic.formalTelephone,
        ),
        isTrue,
      );
      expect(notifier.currentPhrase?.id, 'phone_introduction');
    });

    test('checks recall answer and resets state on next phrase', () async {
      final notifier = BerufsspracheNotifier(repository: repository);
      addTearDown(notifier.dispose);

      await notifier.filterByTopic(WorkplaceTopic.politeRequests);
      final phrase = notifier.currentPhrase!;
      await notifier.checkGerman(phrase.german);

      expect(notifier.lastAnswerCorrect, isTrue);
      expect(notifier.feedbackArabic, isNotEmpty);

      notifier.nextPhrase();
      expect(notifier.lastAnswerCorrect, isNull);
      expect(notifier.feedbackArabic, isNull);
      expect(notifier.currentPhrase?.id, 'request_send_version');
    });

    test('toggles Arabic explanation without changing the active phrase',
        () async {
      final notifier = BerufsspracheNotifier(repository: repository);
      addTearDown(notifier.dispose);
      await notifier.load();
      final id = notifier.currentPhrase!.id;

      notifier.toggleArabic();

      expect(notifier.showArabic, isFalse);
      expect(notifier.currentPhrase!.id, id);
    });

    test('presentation entry point is constructible with the feature notifier',
        () {
      final notifier = BerufsspracheNotifier(repository: repository);
      addTearDown(notifier.dispose);

      final screen = BerufsspracheScreen(notifier: notifier);

      expect(screen, isA<BerufsspracheScreen>());
    });
  });
}
