import '../core/content_contract.dart';
import 'preferences_service.dart';
import 'learner_persistence.dart';
import '../models/learner.dart';
import 'srs.dart';
import '../models/assessment.dart';

/// Local learner-state storage. This app deliberately has no network trust boundary.
/// Persisted values are treated as untrusted input and are bounded before use.
class LearnerRepository {
  final PreferencesService prefs;
  LearnerRepository(this.prefs, {required this.persistence});

  final LearnerPersistence persistence;
  static const key = 'v34_state';
  static const legacyFavoriteKey = 'verb_favorites_v1';
  static const maxAttempts = LearnerPersistence.maxAttempts;
  static const maxCollectionItems = LearnerPersistence.maxCollectionItems;
  static const maxXp = LearnerPersistence.maxXp;
  static const maxStreak = LearnerPersistence.maxStreak;
  Future<void> _writeQueue = Future<void>.value();
  LearnerState? _cachedState;

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final next = _writeQueue.then((_) => action());
    _writeQueue = next.then<void>((_) {}).catchError((_) {});
    return next;
  }

  static const maxMistakeProgress = 5000;

  LearnerState load() {
    final cached = _cachedState;
    if (cached != null) return cached;
    final loaded = _loadFromPrefs();
    _cachedState = loaded;
    return loaded;
  }

  /// Reloads the persisted state when another persistence actor may have changed it.
  /// Normal reads stay cached; callers that explicitly need storage truth use this boundary.
  LearnerState reload() {
    _cachedState = null;
    return load();
  }

  /// Reloads persisted state after all writes already queued by this repository finish.
  /// This prevents a synchronous storage read from observing a pre-write snapshot.
  Future<LearnerState> reloadPersisted() async {
    await _writeQueue;
    _cachedState = null;
    return load();
  }

  LearnerState _loadFromPrefs() => persistence.load();

  Future<void> save(LearnerState s) => _enqueue(() async {
    final persisted = persistence.normalize(s);
    await persistence.save(persisted);
    _cachedState = persisted;
  });

  Future<Set<String>> loadAndMigrateFavoriteVerbs() => _enqueue(() async {
    final result = await persistence.loadAndMigrateFavoriteVerbs(load());
    _cachedState = result;
    return result.favoriteVerbs;
  });

  Future<bool> clearLocalData() => _enqueue<bool>(() async {
    try {
      return await persistence.clearLocalData();
    } finally {
      _cachedState = null;
    }
  });

  Future<void> recordAssessment(AssessmentResult result) => _enqueue(() async {
    final s = load();
    final history = [
      AssessmentHistory(id: result.id, at: result.at, score: result.score, weakSkills: result.weakSkills, answered: result.answered),
      ...s.assessmentHistory,
    ].take(100).toList();
    await _saveNow(s.copyWith(assessmentHistory: history));
  });

  Future<void> recordWritingMistake({required String issue, DateTime? at}) => _enqueue(() async {
    final s = load();
    final key = 'writing:${issue.trim().toLowerCase()}';
    final now = at ?? DateTime.now();
    final attempt = Attempt(id: 'w_${now.microsecondsSinceEpoch}', itemId: key, skill: 'writing', answer: issue.trim(), correct: false, hinted: false, seconds: 5, at: now);
    final attempts = [...s.attempts, attempt];
    await _saveNow(s.copyWith(attempts: attempts.length > maxAttempts ? attempts.sublist(attempts.length-maxAttempts) : attempts));
  });

  Future<void> toggleFavoriteVerb(String infinitive) => _enqueue(() async {
    final value = infinitive.trim();
    if (value.isEmpty || value.length > 120) return;
    final s = load();
    final f = {...s.favoriteVerbs};
    if (f.contains(value)) f.remove(value);
    else if (f.length < maxCollectionItems) f.add(value);
    await _saveNow(s.copyWith(favoriteVerbs: f));
  });

  Future<void> _saveNow(LearnerState s) async {
    final persisted = persistence.normalize(s);
    await persistence.save(persisted);
    _cachedState = persisted;
  }

  Future<void> record({
    required LearningContent item,
    required String answer,
    required bool correct,
    required int seconds,
    required bool hinted,
    String? skillOverride,
  }) => _enqueue(() async {
    final s = load();
    final now = DateTime.now();
    final attempt = Attempt(
      id: 'a_${now.microsecondsSinceEpoch}',
      itemId: item.id,
      skill: skillOverride ?? item.skill,
      answer: answer.length > 1000 ? answer.substring(0, 1000) : answer,
      correct: correct,
      hinted: hinted,
      seconds: seconds.clamp(0, 3600),
      at: now,
    );
    final a = [...s.attempts, attempt];
    final bounded = a.length > maxAttempts ? a.sublist(a.length - maxAttempts) : a;
    final review = {...s.review};
    final cards = {...s.reviewCards};
    final currentCard = cards[item.id] ?? ReviewCard(itemId: item.id, dueAt: now);
    final updatedCard = Srs.update(currentCard, correct: correct, hinted: hinted, now: now);
    cards[item.id] = updatedCard;
    if (correct && updatedCard.repetitions >= 2) review.remove(item.id); else review.add(item.id);
    final learned = {...s.learned};
    if (correct) learned.add(item.id);
    final last = s.attempts.isEmpty ? null : s.attempts.last.at;
    final today = DateTime(now.year, now.month, now.day);
    final sameDay = last != null && DateTime(last.year, last.month, last.day) == today;
    final yesterday = last != null && today.difference(DateTime(last.year, last.month, last.day)).inDays == 1;
    final nextStreak = s.attempts.isEmpty ? 1 : (sameDay ? s.streak : (yesterday ? s.streak + 1 : 1));
    await _saveNow(s.copyWith(
      xp: (s.xp + (correct ? 10 : 2)).clamp(0, maxXp),
      streak: nextStreak.clamp(0, maxStreak),
      learned: learned,
      review: review,
      reviewCards: cards,
      attempts: bounded,
    ));
  });

  Future<void> recordConversationAttempt({required String itemId, required String skill, required String answer, required bool correct, required int seconds, required bool hinted}) => _enqueue(() async {
    final s = load();
    final now = DateTime.now();
    final safeId = itemId.trim();
    if (safeId.isEmpty || safeId.length > 160) return;
    final attempt = Attempt(id:'c_${now.microsecondsSinceEpoch}', itemId:safeId, skill:skill.trim().isEmpty?'production':skill.trim(), answer:answer.length>1000?answer.substring(0,1000):answer, correct:correct, hinted:hinted, seconds:seconds.clamp(0,3600).toInt(), at:now);
    final bounded = [...s.attempts, attempt];
    final kept = bounded.length > maxAttempts ? bounded.sublist(bounded.length-maxAttempts) : bounded;
    await _saveNow(s.copyWith(xp:(s.xp+(correct?10:2)).clamp(0,maxXp), attempts:kept));
  });

}
