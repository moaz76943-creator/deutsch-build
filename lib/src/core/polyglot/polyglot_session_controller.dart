import 'dart:async';
import 'polyglot_unified_core.dart';
import 'polyglot_srs_and_pack_loader.dart';
import 'polyglot_exercise_generator.dart';
import 'modules/german_c1_c2_core_pack.dart';
import 'modules/german_real_world_dialogues_pack.dart';
import 'modules/unified_legacy_engines_pack.dart';

/// لقطة حالة جلسة التدريب التفاعلية (متوافقة مع تحديثات 144Hz بدون إعادة بناء ثقيلة)
class PolyglotSessionState {
  final String languageCode;
  final List<PolyglotGeneratedExercise> exercises;
  final int currentIndex;
  final int correctCount;
  final int answeredCount;
  final ExerciseSubmissionResult? lastResult;
  final bool isCompleted;

  const PolyglotSessionState({
    required this.languageCode,
    required this.exercises,
    required this.currentIndex,
    required this.correctCount,
    required this.answeredCount,
    this.lastResult,
    required this.isCompleted,
  });

  PolyglotGeneratedExercise? get currentExercise =>
      (!isCompleted && currentIndex < exercises.length)
          ? exercises[currentIndex]
          : null;

  double get accuracyRate =>
      answeredCount == 0 ? 0.0 : (correctCount / answeredCount);

  double get progressRatio =>
      exercises.isEmpty ? 1.0 : (currentIndex / exercises.length).clamp(0.0, 1.0);
}

/// مُهيئ المنصة الفوري بضغطة واحدة (Zero-Boilerplate Bootstrap)
class PolyglotAppBootstrap {
  final PolyglotUnifiedRegistry registry;
  final PolyglotSrsScheduler srsScheduler;
  final PolyglotExerciseGenerator exerciseGenerator;
  final PolyglotUnifiedUiBridge uiBridge;

  PolyglotAppBootstrap._({
    required this.registry,
    required this.srsScheduler,
    required this.exerciseGenerator,
    required this.uiBridge,
  });

  /// تهيئة المنصة كاملة دون اتصال مع تسجيل كافة الحزم الأساسية وحزم JSON الإضافية
  factory PolyglotAppBootstrap.initialize({
    List<String> extraJsonPacks = const [],
    String? savedSrsProgressJson,
  }) {
    final registry = PolyglotUnifiedRegistry()
      ..registerModule(GermanC1C2CoreFeaturePack())
      ..registerModule(GermanRealWorldDialoguesPack())
      ..registerModule(UnifiedLegacyEnginesFeaturePack());

    for (final rawJson in extraJsonPacks) {
      PolyglotJsonPackLoader.loadIntoRegistry(registry, rawJson);
    }

    final srs = PolyglotSrsScheduler();
    if (savedSrsProgressJson != null && savedSrsProgressJson.isNotEmpty) {
      srs.importProgressJson(savedSrsProgressJson);
    }

    final generator = PolyglotExerciseGenerator(
      registry: registry,
      srsScheduler: srs,
    );
    final bridge = PolyglotUnifiedUiBridge(registry: registry);

    return PolyglotAppBootstrap._(
      registry: registry,
      srsScheduler: srs,
      exerciseGenerator: generator,
      uiBridge: bridge,
    );
  }

  PolyglotStudySessionController createSessionController() {
    return PolyglotStudySessionController(generator: exerciseGenerator);
  }

  Future<void> dispose() async {
    await uiBridge.dispose();
  }
}

/// متحكم جلسة التعلم التفاعلية (يدير التدفق الكامل من السؤال إلى التقييم والتحديث)
class PolyglotStudySessionController {
  final PolyglotExerciseGenerator generator;
  final StreamController<PolyglotSessionState> _controller =
      StreamController<PolyglotSessionState>.broadcast();

  PolyglotSessionState _state = const PolyglotSessionState(
    languageCode: 'de',
    exercises: [],
    currentIndex: 0,
    correctCount: 0,
    answeredCount: 0,
    isCompleted: true,
  );

  PolyglotStudySessionController({required this.generator});

  Stream<PolyglotSessionState> get stateStream => _controller.stream;
  PolyglotSessionState get state => _state;

  void startSession({
    String languageCode = 'de',
    int limit = 10,
    int seed = 4989,
    DateTime? now,
  }) {
    final items = generator.generateDueSession(
      languageCode: languageCode,
      limit: limit,
      seed: seed,
      now: now,
    );
    _state = PolyglotSessionState(
      languageCode: languageCode,
      exercises: items,
      currentIndex: 0,
      correctCount: 0,
      answeredCount: 0,
      lastResult: null,
      isCompleted: items.isEmpty,
    );
    _emit();
  }

  ExerciseSubmissionResult? submitAnswer(int optionIndex, {DateTime? now}) {
    final current = _state.currentExercise;
    if (current == null) return null;

    final result = generator.submitAnswer(current, optionIndex, now: now);
    _state = PolyglotSessionState(
      languageCode: _state.languageCode,
      exercises: _state.exercises,
      currentIndex: _state.currentIndex,
      correctCount: _state.correctCount + (result.isCorrect ? 1 : 0),
      answeredCount: _state.answeredCount + 1,
      lastResult: result,
      isCompleted: _state.isCompleted,
    );
    _emit();
    return result;
  }

  void advanceToNext() {
    if (_state.isCompleted) return;
    final nextIdx = _state.currentIndex + 1;
    final done = nextIdx >= _state.exercises.length;
    _state = PolyglotSessionState(
      languageCode: _state.languageCode,
      exercises: _state.exercises,
      currentIndex: done ? _state.exercises.length : nextIdx,
      correctCount: _state.correctCount,
      answeredCount: _state.answeredCount,
      lastResult: null,
      isCompleted: done,
    );
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(_state);
    }
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
