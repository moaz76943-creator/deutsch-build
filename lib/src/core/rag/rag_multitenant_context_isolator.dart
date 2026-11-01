import 'dart:math' as math;

enum CorpusScope {
  sharedSystemPublic, // Shared universal grammar rules, dictionary definitions
  learnerPrivateEncrypted, // Personal dialogue history, notes, private mistakes
}

class TenantVectorRecord {
  final String recordId;
  final String tenantId;
  final CorpusScope scope;
  final List<double> vector;
  final String text;
  final Map<String, dynamic> metadata;

  const TenantVectorRecord({
    required this.recordId,
    required this.tenantId,
    required this.scope,
    required this.vector,
    required this.text,
    this.metadata = const {},
  });
}

class IsolatedQueryResult {
  final TenantVectorRecord record;
  final double similarity;

  const IsolatedQueryResult({
    required this.record,
    required this.similarity,
  });
}

/// Sovereign on-device multi-tenant RAG context isolator.
/// Guarantees that vector retrieval strictly confines queries to shared public data
/// and the active tenant's private namespace, eliminating cross-profile data leakage.
class RagMultiTenantContextIsolator {
  final Map<String, TenantVectorRecord> _records = {};

  RagMultiTenantContextIsolator();

  int get recordCount => _records.length;

  void insertRecord(TenantVectorRecord record) {
    _records[record.recordId] = record;
  }

  void purgeTenant(String tenantId) {
    _records.removeWhere((_, r) => r.tenantId == tenantId && r.scope == CorpusScope.learnerPrivateEncrypted);
  }

  static double _cosineSim(List<double> v1, List<double> v2) {
    if (v1.length != v2.length || v1.isEmpty) return 0.0;
    double dot = 0.0, n1 = 0.0, n2 = 0.0;
    for (int i = 0; i < v1.length; i++) {
      dot += v1[i] * v2[i];
      n1 += v1[i] * v1[i];
      n2 += v2[i] * v2[i];
    }
    if (n1 == 0.0 || n2 == 0.0) return 0.0;
    return (dot / (math.sqrt(n1) * math.sqrt(n2))).clamp(-1.0, 1.0);
  }

  /// Queries the vector store while enforcing strict tenant isolation boundaries.
  List<IsolatedQueryResult> query({
    required String activeTenantId,
    required List<double> queryVector,
    double minSimilarity = 0.5,
    int topK = 10,
  }) {
    final matches = <IsolatedQueryResult>[];

    for (final record in _records.values) {
      // Access Rule: record must be shared system public OR belong to the active tenant
      final hasAccess = record.scope == CorpusScope.sharedSystemPublic ||
          (record.scope == CorpusScope.learnerPrivateEncrypted && record.tenantId == activeTenantId);

      if (!hasAccess) continue;

      final sim = _cosineSim(queryVector, record.vector);
      if (sim >= minSimilarity) {
        matches.add(IsolatedQueryResult(record: record, similarity: sim));
      }
    }

    matches.sort((a, b) => b.similarity.compareTo(a.similarity));

    if (topK > 0 && matches.length > topK) {
      return matches.sublist(0, topK);
    }
    return matches;
  }
}
