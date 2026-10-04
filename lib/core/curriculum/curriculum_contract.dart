import 'advanced_vocabulary.dart';
import 'canonical_curriculum_50.dart';
import 'curriculum_models.dart';
import 'learning_path_engine.dart';

void main() {
  final tasks = CanonicalCurriculum50.tasks;
  _expect(tasks.length, 50, 'canonical curriculum must contain exactly 50 tasks');
  _expect(
    tasks.map((task) => task.id).toSet().length,
    50,
    'curriculum task ids must be unique',
  );

  final engine = LearningPathEngine(tasks);
  final validation = engine.validateGraph();
  if (!validation.isValid) {
    throw StateError('Curriculum graph invalid: ${validation.errors.join('; ')}');
  }

  var progress = CurriculumProgress.empty();
  final first = engine.recommend(progress, limit: 3);
  _expect(first.first.task.id, 'task-01', 'first curriculum task');
  _expect(
    first.where((item) => item.unlocked).length,
    1,
    'only the first task may be unlocked before prerequisites are met',
  );

  progress = engine.recordOutcome(
    progress,
    const CurriculumTaskOutcome(
      taskId: 'task-01',
      score: 0.62,
      completed: false,
      attempts: 1,
    ),
  );
  _expect(
    engine.nextRequired(progress)?.id,
    'task-01',
    'incomplete task remains current',
  );

  progress = engine.recordOutcome(
    progress,
    const CurriculumTaskOutcome(
      taskId: 'task-01',
      score: 0.88,
      completed: true,
      attempts: 2,
    ),
  );
  _expect(
    engine.nextRequired(progress)?.id,
    'task-02',
    'completing task-01 unlocks task-02',
  );
  _expect(
    engine.progressRatio(progress),
    0.02,
    'one of fifty tasks equals two percent progress',
  );

  for (var number = 2; number <= 10; number++) {
    final id = 'task-${number.toString().padLeft(2, '0')}';
    progress = engine.recordOutcome(
      progress,
      CurriculumTaskOutcome(
        taskId: id,
        score: 0.9,
        completed: true,
        attempts: 1,
      ),
    );
  }
  _expect(
    engine.nextRequired(progress)?.id,
    'task-11',
    'stage transition must continue to task-11',
  );

  final noun = AdvancedVocabularyEntry(
    id: 'vocab-termin',
    sourceText: 'Termin',
    translationText: 'موعد',
    exampleText: 'Ich habe morgen einen Termin.',
    exampleTranslationText: 'لدي موعد غداً.',
    topic: 'appointments',
    skill: 'vocabulary',
    level: CefrLevel.a1,
    partOfSpeech: VocabularyPartOfSpeech.noun,
    article: GermanArticle.der,
    pluralForm: 'Termine',
    grammaticalMarker: 'der',
    acceptedForms: const <String>['Termin', 'der Termin', 'Termine'],
    pronunciation: const PronunciationData(
      ipa: '/tɛʁˈmiːn/',
      stressHint: 'zweite Silbe',
    ),
    tags: const <String>{'alltag', 'planung'},
  );
  _expect(noun.articleText, 'der', 'noun article');
  _expect(noun.flashcard.frontText, 'Termin', 'flashcard front');
  _expect(noun.flashcard.backText, 'موعد', 'flashcard back');
  _expect(noun.flashcard.article, 'der', 'flashcard article');
  _expect(noun.toLearningContent().id, noun.id, 'LearningContent compatibility');

  final verb = AdvancedVocabularyEntry(
    id: 'vocab-anrufen',
    sourceText: 'anrufen',
    translationText: 'يتصل هاتفياً',
    exampleText: 'Ich rufe dich morgen an.',
    exampleTranslationText: 'سأتصل بك غداً.',
    topic: 'communication',
    skill: 'production',
    level: CefrLevel.a1,
    partOfSpeech: VocabularyPartOfSpeech.verb,
    grammaticalMarker: 'trennbar',
    acceptedForms: const <String>['anrufen', 'ruft an', 'angerufen'],
    verbData: const VerbMorphology(
      thirdPersonPresent: 'ruft an',
      preterite: 'rief an',
      perfectAuxiliary: PerfectAuxiliary.haben,
      pastParticiple: 'angerufen',
      separable: true,
    ),
  );
  _expect(verb.verbData?.separable, true, 'separable verb metadata');
  _expect(
    verb.verbData?.perfectDisplay,
    'hat angerufen',
    'perfect projection',
  );

  final bank = AdvancedVocabularyBank(
    id: 'daily-a1',
    entries: <AdvancedVocabularyEntry>[noun, verb],
  );
  _expect(bank.entries.length, 2, 'vocabulary bank size');
  _expect(bank.byId('vocab-anrufen').sourceText, 'anrufen', 'bank lookup');
  _expect(bank.flashcards.length, 2, 'bank flashcard projections');
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}
