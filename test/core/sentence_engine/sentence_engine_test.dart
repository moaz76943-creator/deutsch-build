import 'package:deutsch_bilarabi/core/sentence_engine/sentence_card.dart';
import 'package:deutsch_bilarabi/core/sentence_engine/sentence_engine.dart';
import 'package:deutsch_bilarabi/core/sentence_engine/sentence_models.dart';
import 'package:deutsch_bilarabi/core/sentence_engine/sentence_tts.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SentenceEntry _sentence() => SentenceEntry(
      id: 'lernen-1',
      german: 'Der Schüler lernt Deutsch.',
      translationAr: 'الطالب يتعلم الألمانية.',
      lexicon: const <SentenceLexeme>[
        SentenceLexeme(
          lemma: 'Schüler',
          forms: <String>{'Schüler'},
          noun: NounGrammar(
            article: GermanArticle.der,
            plural: 'Schüler',
            grammaticalCase: GermanCase.nominative,
          ),
          syntaxRoleDe: 'Subjekt',
          syntaxRoleAr: 'الفاعل',
        ),
        SentenceLexeme(
          lemma: 'lernen',
          forms: <String>{'lernt'},
          verb: VerbConjugation(
            present: 'lernt',
            preterite: 'lernte',
            perfect: 'hat gelernt',
            prepositions: <String>['für + Akkusativ'],
          ),
          syntaxRoleDe: 'Prädikat',
          syntaxRoleAr: 'فعل الجملة',
        ),
      ],
      syntaxBreakdown: const <SyntaxSegment>[
        SyntaxSegment(
          labelDe: 'Subjekt',
          labelAr: 'الفاعل',
          text: 'Der Schüler',
        ),
        SyntaxSegment(
          labelDe: 'Prädikat',
          labelAr: 'الفعل',
          text: 'lernt',
        ),
        SyntaxSegment(
          labelDe: 'Objekt',
          labelAr: 'المفعول',
          text: 'Deutsch',
        ),
      ],
      wordOrderPattern: SentenceWordOrderPattern.svo,
    );

SentenceEntry _weatherSentence() => const SentenceEntry(
      id: 'weather-1',
      german: 'Heute regnet es.',
      translationAr: 'تمطر اليوم.',
    );

SentenceEntry _subordinateSentence() => const SentenceEntry(
      id: 'subordinate-1',
      german: 'Ich bleibe zu Hause, weil es regnet.',
      translationAr: 'أبقى في المنزل لأن الجو ممطر.',
    );

SentenceEntry _modalSentence() => const SentenceEntry(
      id: 'modal-1',
      german: 'Ich muss heute lernen.',
      translationAr: 'يجب أن أدرس اليوم.',
      lexicon: <SentenceLexeme>[
        SentenceLexeme(
          lemma: 'müssen',
          forms: <String>{'muss'},
          verb: VerbConjugation(
            present: 'muss',
            preterite: 'musste',
            perfect: 'hat gemusst',
            isModal: true,
          ),
        ),
      ],
    );

void main() {
  group('SentenceAnalysisEngine', () {
    test('tokenizes punctuation and attaches noun and verb grammar', () {
      final engine = SentenceAnalysisEngine();

      final tokens = engine.analyze(_sentence());

      expect(
        tokens.map((token) => token.text).toList(),
        <String>['Der', 'Schüler', 'lernt', 'Deutsch', '.'],
      );

      final noun = tokens[1];
      expect(noun.noun?.article, GermanArticle.der);
      expect(noun.noun?.plural, 'Schüler');
      expect(noun.noun?.grammaticalCase, GermanCase.nominative);

      final verb = tokens[2];
      expect(verb.verb?.present, 'lernt');
      expect(verb.verb?.preterite, 'lernte');
      expect(verb.verb?.perfect, 'hat gelernt');
      expect(verb.verb?.prepositions, <String>['für + Akkusativ']);

      expect(tokens.last.isPunctuation, isTrue);
    });

    test('detects SVO, subordinate verb-final, and modal brackets', () {
      final engine = SentenceAnalysisEngine();

      expect(
        engine.detectWordOrderPattern(_sentence()),
        SentenceWordOrderPattern.svo,
      );
      expect(
        engine.detectWordOrderPattern(_subordinateSentence()),
        SentenceWordOrderPattern.subordinateVerbFinal,
      );
      expect(
        engine.detectWordOrderPattern(_modalSentence()),
        SentenceWordOrderPattern.modalBracket,
      );
    });
  });

  group('SentenceFuzzySearchService', () {
    test('tolerates German diacritics and small spelling typos', () {
      final search = SentenceFuzzySearchService(
        <SentenceEntry>[_weatherSentence(), _sentence()],
      );

      final hits = search.search('Schuler lernnt');

      expect(hits, isNotEmpty);
      expect(hits.first.sentence.id, 'lernen-1');
      expect(hits.first.score, greaterThan(.5));
    });

    test('matches Arabic phonetic spelling against German sentence', () {
      final search = SentenceFuzzySearchService(
        <SentenceEntry>[_weatherSentence(), _sentence()],
      );

      final hits = search.search('شولر ليرنت دويتش');

      expect(hits, isNotEmpty);
      expect(hits.first.sentence.id, 'lernen-1');
      expect(hits.first.score, greaterThan(.5));
    });

    test('uses explicit phonetic aliases as additional search evidence', () {
      final sentence = SentenceEntry(
        id: 'alias-1',
        german: 'Guten Morgen.',
        translationAr: 'صباح الخير.',
        phoneticAliases: const <String>['غوتن مورغن'],
      );
      final search = SentenceFuzzySearchService(<SentenceEntry>[sentence]);

      final hits = search.search('غوتن مورغن');

      expect(hits, hasLength(1));
      expect(hits.single.score, 1);
    });

    test('empty fuzzy query returns no hits', () {
      final search = SentenceFuzzySearchService(<SentenceEntry>[_sentence()]);

      expect(search.search('   '), isEmpty);
    });
  });

  group('AudioPlaybackController', () {
    test('toggles speed and exposes deterministic playback states', () async {
      String? spoken;
      String? locale;
      double? speed;
      var stopCalls = 0;
      final hook = CallbackSentenceTtsHook(
        offlineReady: true,
        rateCallback: (value) async {
          speed = value;
        },
        speakCallback: (text, languageCode) async {
          spoken = text;
          locale = languageCode;
        },
        stopCallback: () async {
          stopCalls += 1;
        },
      );
      final controller = AudioPlaybackController(hook: hook);

      expect(controller.state, AudioPlaybackState.idle);
      expect(controller.speed, AudioPlaybackSpeed.normal);

      controller.toggleSpeed();
      expect(controller.speed, AudioPlaybackSpeed.slow);

      final started = await controller.play(
        'Guten Morgen.',
        languageCode: 'de-DE',
      );

      expect(started, isTrue);
      expect(controller.state, AudioPlaybackState.playing);
      expect(spoken, 'Guten Morgen.');
      expect(locale, 'de-DE');
      expect(speed, .75);

      controller.markCompleted();
      expect(controller.state, AudioPlaybackState.idle);

      await controller.stop();
      expect(controller.state, AudioPlaybackState.stopped);
      expect(stopCalls, 1);
    });

    test('fails closed when audio backend is unavailable', () async {
      final hook = CallbackSentenceTtsHook(
        offlineReady: false,
        speakCallback: (_, __) async {},
      );
      final controller = AudioPlaybackController(hook: hook);

      final started = await controller.play('Hallo.');

      expect(started, isFalse);
      expect(controller.state, AudioPlaybackState.unavailable);
    });
  });

  testWidgets(
      'InteractiveSentenceCard exposes chips, grammar sheet and audio speed control',
      (tester) async {
    var spokenSpeed = 0.0;
    var ttsCalls = 0;
    var stopCalls = 0;
    final hook = CallbackSentenceTtsHook(
      offlineReady: true,
      rateCallback: (value) async {
        spokenSpeed = value;
      },
      speakCallback: (_, __) async {
        ttsCalls += 1;
      },
      stopCallback: () async {
        stopCalls += 1;
      },
    );
    final controller = AudioPlaybackController(hook: hook);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InteractiveSentenceCard(
            sentence: _sentence(),
            engine: SentenceAnalysisEngine(),
            audioController: controller,
          ),
        ),
      ),
    );

    expect(find.byType(AppGlassCard), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(ActionChip), findsNWidgets(4));
    expect(find.text('Der Schüler lernt Deutsch.'), findsOneWidget);
    expect(find.text('الطالب يتعلم الألمانية.'), findsNothing);
    expect(find.text('1.0x'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('sentence-translation-toggle')),
    );
    await tester.pump();
    expect(find.text('الطالب يتعلم الألمانية.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('sentence-token-1')));
    await tester.pumpAndSettle();
    expect(find.text('der'), findsOneWidget);
    expect(find.text('Plural: Schüler'), findsOneWidget);
    expect(find.text('Kasus: Nominativ'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('sentence-sheet-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('sentence-token-2')));
    await tester.pumpAndSettle();
    expect(find.text('Präsens: lernt'), findsOneWidget);
    expect(find.text('Präteritum: lernte'), findsOneWidget);
    expect(find.text('Perfekt: hat gelernt'), findsOneWidget);
    expect(find.text('Präpositionen: für + Akkusativ'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('sentence-sheet-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('sentence-syntax-button')));
    await tester.pumpAndSettle();
    expect(find.byType(GrammarBreakdownSheet), findsOneWidget);
    expect(find.text('SVO / V2'), findsOneWidget);
    expect(
      find.textContaining('الفعل المصرف غالبًا في الموقع الثاني'),
      findsOneWidget,
    );
    expect(find.text('Der Schüler'), findsOneWidget);
    expect(find.text('الفاعل'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('sentence-sheet-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('sentence-speed-toggle')));
    await tester.pump();
    expect(find.text('0.75x'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('sentence-tts-button')));
    await tester.pump();
    expect(ttsCalls, 1);
    expect(spokenSpeed, .75);
    expect(controller.state, AudioPlaybackState.playing);
    expect(find.text('يتم التشغيل'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('sentence-tts-button')));
    await tester.pump();
    expect(stopCalls, 1);
    expect(controller.state, AudioPlaybackState.stopped);
  });
}
