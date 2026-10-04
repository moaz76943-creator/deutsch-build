enum AgentDataDomain {
  vocabulary,
  grammar,
}

enum AgentDataIntegrityCode {
  duplicateEntry,
  conflictingEntry,
  crossPairIdCollision,
  recordIdCollision,
  invalidRecord,
}

final class AgentDataRecord {
  const AgentDataRecord({
    required this.recordId,
    required this.domain,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.canonicalKey,
    required this.fingerprint,
  });

  final String recordId;
  final AgentDataDomain domain;
  final String sourceLanguage;
  final String targetLanguage;
  final String canonicalKey;
  final String fingerprint;

  String get directedPairKey =>
      _language(sourceLanguage) + '->' + _language(targetLanguage);

  String get entryKey =>
      domain.name + '|' + directedPairKey + '|' + canonicalKey.trim();

  AgentDataRecord normalized() => AgentDataRecord(
        recordId: recordId.trim(),
        domain: domain,
        sourceLanguage: _language(sourceLanguage),
        targetLanguage: _language(targetLanguage),
        canonicalKey: canonicalKey.trim(),
        fingerprint: fingerprint.trim(),
      );

  bool get isStructurallyValid =>
      recordId.trim().isNotEmpty &&
      _validLanguage(sourceLanguage) &&
      _validLanguage(targetLanguage) &&
      canonicalKey.trim().isNotEmpty &&
      fingerprint.trim().isNotEmpty;
}

final class AgentDataIntegrityIssue {
  const AgentDataIntegrityIssue({
    required this.code,
    required this.recordId,
    required this.message,
  });

  final AgentDataIntegrityCode code;
  final String recordId;
  final String message;
}

final class AgentDataIntegrityReport {
  AgentDataIntegrityReport({
    required this.checkedRecords,
    required List<AgentDataIntegrityIssue> issues,
  }) : issues = List<AgentDataIntegrityIssue>.unmodifiable(issues);

  final int checkedRecords;
  final List<AgentDataIntegrityIssue> issues;

  bool get isValid => issues.isEmpty;

  bool hasCode(AgentDataIntegrityCode code) =>
      issues.any((issue) => issue.code == code);
}

final class AgentDataIntegrityVerifier {
  const AgentDataIntegrityVerifier();

  AgentDataIntegrityReport verify(Iterable<AgentDataRecord> records) {
    final issues = <AgentDataIntegrityIssue>[];
    final entries = <String, AgentDataRecord>{};
    final ids = <String, AgentDataRecord>{};
    var checked = 0;

    for (final raw in records) {
      checked += 1;
      if (!raw.isStructurallyValid) {
        issues.add(
          AgentDataIntegrityIssue(
            code: AgentDataIntegrityCode.invalidRecord,
            recordId: raw.recordId.trim(),
            message: 'Record contains an empty or invalid identity field.',
          ),
        );
        continue;
      }

      final record = raw.normalized();
      final previousEntry = entries[record.entryKey];
      if (previousEntry != null) {
        final sameContent =
            previousEntry.fingerprint == record.fingerprint;
        issues.add(
          AgentDataIntegrityIssue(
            code: sameContent
                ? AgentDataIntegrityCode.duplicateEntry
                : AgentDataIntegrityCode.conflictingEntry,
            recordId: record.recordId,
            message: sameContent
                ? 'Duplicate ${record.domain.name} entry for '
                    '${record.directedPairKey}:${record.canonicalKey}.'
                : 'Conflicting ${record.domain.name} entry for '
                    '${record.directedPairKey}:${record.canonicalKey}.',
          ),
        );
      } else {
        entries[record.entryKey] = record;
      }

      final previousId = ids[record.recordId];
      if (previousId == null) {
        ids[record.recordId] = record;
        continue;
      }

      if (previousId.directedPairKey != record.directedPairKey) {
        issues.add(
          AgentDataIntegrityIssue(
            code: AgentDataIntegrityCode.crossPairIdCollision,
            recordId: record.recordId,
            message: 'Record id crosses directed language pairs: '
                '${previousId.directedPairKey} vs '
                '${record.directedPairKey}.',
          ),
        );
        continue;
      }

      if (previousId.entryKey != record.entryKey ||
          previousId.fingerprint != record.fingerprint) {
        issues.add(
          AgentDataIntegrityIssue(
            code: AgentDataIntegrityCode.recordIdCollision,
            recordId: record.recordId,
            message: 'Record id maps to conflicting content.',
          ),
        );
      }
    }

    return AgentDataIntegrityReport(
      checkedRecords: checked,
      issues: issues,
    );
  }
}

String _language(String value) =>
    value.trim().replaceAll('_', '-').toLowerCase();

bool _validLanguage(String value) {
  final normalized = _language(value);
  if (normalized.isEmpty || normalized.length > 35) return false;
  return RegExp(
    r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$',
    caseSensitive: false,
  ).hasMatch(normalized);
}
