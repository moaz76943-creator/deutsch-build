import 'package:deutsch_bilarabi/core/quick_review/quick_review.dart';
import 'package:deutsch_bilarabi/models/learner.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeQuickReviewCorpusReader
    implements QuickReviewCorpusReader {
  _FakeQuickReviewCorpusReader(this.items);

  final Map<String, QuickReviewCorpusItem> items;
  int queryCount = 0;
  List<String> lastIds = const <String>[];

  @override
  Future<List<QuickReviewCorpusItem>> fetchByIds(
    Iterable<String> contentIds,
  ) async {
    queryCount += 1;
    lastIds = contentIds.toList(growable: false);
    return <QuickReviewCorpusItem>[
      for (final id in lastIds)
        if (items[id] != null) items[id]!,
    ];
  }
}

void main() {
  test('buildSession ranks due cards and performs one bounded corpus query',
      () async {
    final now = DateTime.utc(2026, 10, 5, 8);
    final reader = _FakeQuickReviewCorpusReader(
      <String, QuickReviewCorpusItem>{
        'late': const QuickReviewCorpusItem(
          id: 'late',
          sourceText: 'spät',
          translationText: 'متأخر',
          exampleText: 'Ich komme spät.',
          exampleTranslationText: 'أنا آتي متأخرًا.',
          grammaticalMarker: '',
          pluralForm: '',
          topic: 'time',
          skill: 'vocabulary',
          acceptedForms: <String>['spät'],
        ),
        'due': const QuickReviewCorpusItem(
          id: 'due',
          sourceText: 'lernen',
          translationText: 'يتعلم',
          exampleText: 'Ich lerne Deutsch.',
          exampleTranslationText: 'أنا أتعلم الألمانية.',
          grammaticalMarker: '',
          pluralForm: '',
        ),
        'future': const QuickReviewCorpusItem(
          id: 'future',
          sourceText: 'morgen',
          translationText: 'غدًا',
          exampleText: 'Bis morgen.',
          exampleTranslationText: 'إلى الغد.',
          grammaticalMarker: '',
          pluralForm: '',
        ),
      },
    );
    final service = QuickReviewService(corpusReader: reader);

    final session = await service.buildSession(
      reviewCards: <ReviewCard>[
        ReviewCard(
          itemId: 'due',
          dueAt: now.subtract(const Duration(minutes: 5)),
        ),
        ReviewCard(
          itemId: 'late',
          dueAt: now.subtract(const Duration(days: 3)),
          lapses: 2,
        ),
        ReviewCard(
          itemId: 'future',
          dueAt: now.add(const Duration(days: 1)),
        ),
      ],
      now: now,
      limit: 12,
    );

    expect(reader.queryCount, 1);
    expect(reader.lastIds, <String>['late', 'due']);
    expect(session.cards.map((card) => card.contentId), <String>['late', 'due']);
    expect(session.cards.every((card) => !card.dueAt.isAfter(now)), isTrue);
    expect(session.cards.first.topic, 'time');
    expect(session.cards.first.skill, 'vocabulary');
    expect(session.cards.first.acceptedForms, <String>['spät']);
    expect(session.limit, 12);
  });

  test('buildSession caps review memory and query size at twenty items',
      () async {
    final now = DateTime.utc(2026, 10, 5, 8);
    final items = <String, QuickReviewCorpusItem>{
      for (var index = 0; index < 40; index += 1)
        'item_$index': QuickReviewCorpusItem(
          id: 'item_$index',
          sourceText: 'Wort $index',
          translationText: 'كلمة $index',
          exampleText: 'Beispiel $index',
          exampleTranslationText: 'مثال $index',
          grammaticalMarker: '',
          pluralForm: '',
        ),
    };
    final reader = _FakeQuickReviewCorpusReader(items);
    final service = QuickReviewService(corpusReader: reader);

    final session = await service.buildSession(
      reviewCards: <ReviewCard>[
        for (var index = 0; index < 40; index += 1)
          ReviewCard(
            itemId: 'item_$index',
            dueAt: now.subtract(Duration(minutes: index + 1)),
          ),
      ],
      now: now,
      limit: 999,
    );

    expect(reader.queryCount, 1);
    expect(reader.lastIds, hasLength(20));
    expect(session.cards, hasLength(20));
    expect(session.limit, 20);
  });

  test('buildSession avoids SQLite work when nothing is due', () async {
    final now = DateTime.utc(2026, 10, 5, 8);
    final reader = _FakeQuickReviewCorpusReader(
      const <String, QuickReviewCorpusItem>{},
    );
    final service = QuickReviewService(corpusReader: reader);

    final session = await service.buildSession(
      reviewCards: <ReviewCard>[
        ReviewCard(
          itemId: 'future',
          dueAt: now.add(const Duration(hours: 1)),
        ),
      ],
      now: now,
    );

    expect(reader.queryCount, 0);
    expect(session.cards, isEmpty);
    expect(session.isEmpty, isTrue);
  });
}
