final class WorkerJob<T> {
  const WorkerJob({
    required this.id,
    required this.type,
    required this.epoch,
    required this.payload,
  });

  final String id;
  final String type;
  final int epoch;
  final T payload;
}

final class WorkerResult<R> {
  const WorkerResult({
    required this.id,
    required this.epoch,
    required this.status,
    required this.payload,
    required this.errorCode,
  });

  final String id;
  final int epoch;
  final String status;
  final R? payload;
  final String? errorCode;
}

abstract final class WorkerJobTypes {
  static const String jsonDecode = 'json.decode';
  static const String checksum128 = 'checksum.128';
  static const String sha256 = 'checksum.sha256';
  static const String fuzzyRank = 'fuzzy.rank';
  static const String srsSchedule = 'srs.schedule';
}

abstract final class WorkerStatuses {
  static const String ok = 'ok';
  static const String error = 'error';
  static const String stale = 'stale';
  static const String closed = 'closed';
}
