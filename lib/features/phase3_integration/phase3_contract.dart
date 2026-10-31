import '../../core/curriculum/advanced_vocabulary.dart';
import '../../core/curriculum/canonical_curriculum_50.dart';
import 'life_curriculum_catalog.dart';
import 'production_agent_runtime.dart';

Future<void> main() async {
  final catalog = LifeCurriculumCatalog.standard();

  _expect(catalog.links.length, 50, 'life catalog contains exactly 50 tasks');
  _expect(
    catalog.links.map((link) => link.featureKey).toSet().length,
    50,
    'life feature keys are unique',
  );
  _expect(
    catalog.links.any((link) => link.featureKey == 'life_maintenance'),
    true,
    'maintenance is the fiftieth life feature',
  );

  final curriculumIds = CanonicalCurriculum50.tasks
      .map((task) => task.id)
      .toSet();
  for (final link in catalog.links) {
    _expect(
      curriculumIds.contains(link.curriculumTaskId),
      true,
      'life task ${link.featureKey} points to a valid curriculum task',
    );
  }

  final projections = <VocabularyFlashcardProjection>[
    const VocabularyFlashcardProjection(
      id: 'haus',
      frontText: 'Haus',
      backText: 'بيت',
      frontLanguageCode: 'de',
      backLanguageCode: 'ar',
      article: 'das',
      frontSupportingText: 'Plural: Häuser',
      backSupportingText: 'Ich bin zu Hause.',
      semanticLabel: 'A1 noun: Haus — بيت',
    ),
  ];
  final decks = VocabularyProjectionDeckRegistry(
    <String, List<VocabularyFlashcardProjection>>{
      'main-vocabulary': projections,
    },
  );

  final runtime = Phase3AgentRuntime.start(
    catalog: catalog,
    decks: decks,
  );

  final design = await runtime.requestDesign();
  _expect(design.navigation, 'bottom', 'design agent selects bottom navigation');
  _expect(design.flashcardMode, '3d', 'design agent selects 3D flashcards');
  _expect(design.direction, 'rtl', 'design agent preserves Arabic RTL shell');

  final route = await runtime.requestRoute('life_maintenance');
  _expect(route.featureKey, 'life_maintenance', 'routing agent resolves feature');
  _expect(
    route.curriculumTaskId.isNotEmpty,
    true,
    'routing agent returns curriculum linkage',
  );

  final cards = await runtime.requestCards('main-vocabulary');
  _expect(cards.deckId, 'main-vocabulary', 'cards agent resolves deck');
  _expect(cards.cardCount, 1, 'cards agent returns projection count');

  var missingDeckRejected = false;
  try {
    await runtime.requestCards('missing-deck');
  } on StateError {
    missingDeckRejected = true;
  }
  _expect(
    missingDeckRejected,
    true,
    'cards agent rejects unknown decks through the event response',
  );

  var missingRouteRejected = false;
  try {
    await runtime.requestRoute('life_missing');
  } on StateError {
    missingRouteRejected = true;
  }
  _expect(
    missingRouteRejected,
    true,
    'routing agent rejects unknown feature keys',
  );

  await runtime.close();
  _expect(runtime.isClosed, true, 'runtime closes streams and endpoints');
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}
