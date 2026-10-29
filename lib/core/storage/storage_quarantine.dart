class QuarantinedData {
  final String id;
  final String rawJson;
  final String diagnosticReason;
  final int timestampEpoch;

  const QuarantinedData({
    required this.id,
    required this.rawJson,
    required this.diagnosticReason,
    required this.timestampEpoch,
  });
}

class StorageQuarantine {
  final List<QuarantinedData> _quarantine = [];
  static const int _retentionDays = 30;

  void isolateCorruptData({
    required String id,
    required String rawJson,
    required String reason,
  }) {
    _enforceBoundedRetention();
    _quarantine.add(QuarantinedData(
      id: id,
      rawJson: rawJson,
      diagnosticReason: reason,
      timestampEpoch: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  List<QuarantinedData> get isolatedItems => List.unmodifiable(_quarantine);
  void clearResolved(String id) {
    _quarantine.removeWhere((item) => item.id == id);
  }

  void _enforceBoundedRetention() {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    const retentionMs = _retentionDays * 24 * 60 * 60 * 1000;
    _quarantine
        .removeWhere((item) => (nowEpoch - item.timestampEpoch) > retentionMs);
  }
}
