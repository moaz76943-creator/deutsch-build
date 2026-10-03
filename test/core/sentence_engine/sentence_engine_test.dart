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
    );

SentenceEntry _weatherSentence() => const SentenceEntry(
      id: 'weather-1',
      german: 'Heute regnet es.',
      translationAr: 'تمطر اليوم.',
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

      expect(tokens.last.isPunctuation, isTrue);
    });

    test('fuzzy search tolerates German diacritics and small typos', () {
      final search = FuzzySentenceSearch(
        <SentenceEntry>[_weatherSentence(), _sentence()],
      );

      final hits = search.search('Schuler lernnt');

      expect(hits, isNotEmpty);
      expect(hits.first.sentence.id, 'lernen-1');
      expect(hits.first.score, greaterThan(.5));
    });

    test('empty fuzzy query returns no hits', () {
      final search = FuzzySentenceSearch(<SentenceEntry>[_sentence()]);

      expect(search.search('   '), isEmpty);
    });
  });

  test('offline TTS callback hook forwards text and locale', () async {
    String? spoken;
    String? locale;
    final hook = CallbackSentenceTtsHook(
      offlineReady: true,
      speakCallback: (text, languageCode) async {
        spoken = text;
        locale = languageCode;
      },
    );

    await hook.speak('Guten Morgen.', languageCode: 'de-DE');

    expect(hook.isOfflineReady, isTrue);
    expect(spoken, 'Guten Morgen.');
    expect(locale, 'de-DE');
  });

  testWidgets(
      'SentenceCard exposes translation, grammar inspector, syntax, TTS and design shell',
      (tester) async {
    var ttsCalls = 0;
    final hook = CallbackSentenceTtsHook(
      offlineReady: true,
      speakCallback: (_, __) async {
        ttsCalls += 1;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SentenceCard(
            sentence: _sentence(),
            engine: SentenceAnalysisEngine(),
            ttsHook: hook,
          ),
        ),
      ),
    );

    expect(find.byType(AppGlassCard), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Der Schüler lernt Deutsch.'), findsOneWidget);
    expect(find.text('الطالب يتعلم الألمانية.'), findsNothing);
    expect(find.byKey(const ValueKey('sentence-copy-button')), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('sentence-translation-toggle')),
    );
    await tester.pump();
    expect(find.text('الطالب يتعلم الألمانية.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sentence-token-1')));
    await tester.pumpAndSettle();
    expect(find.text('der'), findsOneWidget);
    expect(find.text('Plural: Schüler'), findsOneWidget);
    expect(find.text('Kasus: Nominativ'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sentence-sheet-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('sentence-token-2')));
    await tester.pumpAndSettle();
    expect(find.text('Präsens: lernt'), findsOneWidget);
    expect(find.text('Präteritum: lernte'), findsOneWidget);
    expect(find.text('Perfekt: hat gelernt'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sentence-sheet-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('sentence-syntax-button')));
    await tester.pumpAndSettle();
    expect(find.text('Syntax · Satzbau'), findsOneWidget);
    expect(find.text('Der Schüler'), findsOneWidget);
    expect(find.text('الفاعل'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sentence-sheet-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('sentence-tts-button')));
    await tester.pump();
    expect(ttsCalls, 1);
  });
}
