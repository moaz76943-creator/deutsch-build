import '../../../core/agents/system_agent_runtime.dart';
import '../domain/verb_conjugation_models.dart';

final class VerbConjugationEngine {
  VerbConjugationEngine({
    required SystemAgentRuntime runtime,
    required Iterable<VerbConjugation> verbs,
  })  : _runtime = runtime,
        _byId = _indexById(verbs),
        _candidateChunks = _buildCandidateChunks(verbs);

  static const int maxCandidatesPerWorkerJob = 5000;

  final SystemAgentRuntime _runtime;
  final Map<String, VerbConjugation> _byId;
  final List<List<Map<String, Object?>>> _candidateChunks;

  int get verbCount => _byId.length;

  VerbConjugation? byId(String id) => _byId[id.trim()];

  Future<List<VerbSearchHit>> search(
    String query, {
    int limit = 20,
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty || _candidateChunks.isEmpty) {
      return const <VerbSearchHit>[];
    }

    final boundedLimit = limit.clamp(1, 100).toInt();
    final batches = await Future.wait(
      _candidateChunks.map(
        (chunk) => _runtime.rankFuzzyCandidates(
          query: normalized,
          candidates: chunk,
          limit: boundedLimit,
        ),
      ),
    );

    final bestScores = <String, double>{};
    for (final batch in batches) {
      if (batch == null) continue;
      for (final row in batch) {
        final id = row['id'];
        final rawScore = row['score'];
        if (id is! String || rawScore is! num || !_byId.containsKey(id)) {
          continue;
        }
        final score = rawScore.toDouble().clamp(0.0, 1.0).toDouble();
        final previous = bestScores[id];
        if (previous == null || score > previous) {
          bestScores[id] = score;
        }
      }
    }

    final hits = bestScores.entries
        .map(
          (entry) => VerbSearchHit(
            verb: _byId[entry.key]!,
            score: entry.value,
          ),
        )
        .toList(growable: false)
      ..sort((left, right) {
        final byScore = right.score.compareTo(left.score);
        if (byScore != 0) return byScore;
        return left.verb.infinitive.compareTo(right.verb.infinitive);
      });

    return List<VerbSearchHit>.unmodifiable(
      hits.take(boundedLimit),
    );
  }

  static Map<String, VerbConjugation> _indexById(
    Iterable<VerbConjugation> verbs,
  ) {
    final indexed = <String, VerbConjugation>{};
    for (final verb in verbs) {
      final id = verb.id.trim();
      if (indexed.containsKey(id)) {
        throw ArgumentError('Duplicate verb id: ' + id);
      }
      indexed[id] = verb;
    }
    return Map<String, VerbConjugation>.unmodifiable(indexed);
  }

  static List<List<Map<String, Object?>>> _buildCandidateChunks(
    Iterable<VerbConjugation> verbs,
  ) {
    final chunks = <List<Map<String, Object?>>>[];
    var current = <Map<String, Object?>>[];

    for (final verb in verbs) {
      if (current.length == maxCandidatesPerWorkerJob) {
        chunks.add(List<Map<String, Object?>>.unmodifiable(current));
        current = <Map<String, Object?>>[];
      }
      current.add(
        <String, Object?>{
          'id': verb.id.trim(),
          'text': verb.searchText,
        },
      );
    }

    if (current.isNotEmpty) {
      chunks.add(List<Map<String, Object?>>.unmodifiable(current));
    }
    return List<List<Map<String, Object?>>>.unmodifiable(chunks);
  }
}
