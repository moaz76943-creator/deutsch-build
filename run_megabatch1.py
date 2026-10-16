import os, subprocess, sys

print("🚀 [Codespaces] بدء تطبيق الحزمة الأولى (0001–0200): المعمارية والتخزين والتعافي التلقائي...")

os.makedirs("lib/core/architecture", exist_ok=True)
os.makedirs("lib/core/models", exist_ok=True)
os.makedirs("lib/core/storage", exist_ok=True)

# 1. DirectedPairId (030, 031, 032)
with open("lib/core/architecture/directed_pair_id.dart", "w", encoding="utf-8") as f:
    f.write("""/// هوية صارمة للزوج اللغوي تمنع الخلط بين الاتجاهين
class DirectedPairId {
  final String sourceLocale;
  final String targetLocale;
  final String semanticVersion;

  const DirectedPairId({
    required this.sourceLocale,
    required this.targetLocale,
    required this.semanticVersion,
  });

  String get uniqueKey => '${sourceLocale}_${targetLocale}_$semanticVersion';
  bool get isReflexive => sourceLocale == targetLocale;
  bool isValidForLearning() => !isReflexive && sourceLocale.isNotEmpty && targetLocale.isNotEmpty;
}
""")

# 2. OperationResult & Failure (072, 073, 074, 075)
with open("lib/core/architecture/operation_result.dart", "w", encoding="utf-8") as f:
    f.write("""/// تغليف صارم لنتائج العمليات لمنع الأخطاء غير المعالجة
abstract class OperationFailure {
  final String code;
  final String message;
  const OperationFailure(this.code, this.message);
}

class StorageFailure extends OperationFailure {
  const StorageFailure(super.code, super.message);
}

class ContentFailure extends OperationFailure {
  const ContentFailure(super.code, super.message);
}

class OperationResult<T> {
  final T? _data;
  final OperationFailure? _failure;

  const OperationResult.success(this._data) : _failure = null;
  const OperationResult.failure(this._failure) : _data = null;

  bool get isSuccess => _failure == null;
  T get data {
    if (!isSuccess || _data == null) throw Exception('Cannot access data of a failed result');
    return _data!;
  }
  OperationFailure get failure => _failure!;
}
""")

# 3. ReviewCommand (057, 058, 059)
with open("lib/core/models/review_command.dart", "w", encoding="utf-8") as f:
    f.write("""import '../architecture/directed_pair_id.dart';

/// أمر مراجعة غير قابل للتعديل يمثل مصدر الحقيقة الوحيد لعمليات التلعيب و SRS
class ReviewCommand {
  final String eventId;
  final DirectedPairId pairId;
  final String cardId;
  final int timestamp;
  final int score;
  final bool usedHint;

  const ReviewCommand({
    required this.eventId,
    required this.pairId,
    required this.cardId,
    required this.timestamp,
    required this.score,
    required this.usedHint,
  });
}
""")

# 4. MigrationJournal (126, 127, 128)
with open("lib/core/storage/migration_journal.dart", "w", encoding="utf-8") as f:
    f.write("""/// سجل ترحيل قواعد البيانات لمنع تكرار التحديثات وحفظ الهوية
class MigrationRecord {
  final String migrationId;
  final int timestampEpoch;
  const MigrationRecord(this.migrationId, this.timestampEpoch);
}

class MigrationJournal {
  final List<MigrationRecord> _records = [];

  void recordMigration(String id) {
    if (!hasMigrated(id)) {
      _records.add(MigrationRecord(id, DateTime.now().millisecondsSinceEpoch));
    }
  }

  bool hasMigrated(String id) => _records.any((r) => r.migrationId == id);
  List<MigrationRecord> get history => List.unmodifiable(_records);
}
""")

# 5. StorageQuarantine (132, 133, 134)
with open("lib/core/storage/storage_quarantine.dart", "w", encoding="utf-8") as f:
    f.write("""/// نظام عزل البيانات التالفة (Quarantine) بدلاً من استبدالها بصمت
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

  void isolateCorruptData({
    required String id,
    required String rawJson,
    required String reason,
  }) {
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
}
""")

# 6. DatabaseHealthMetrics (195, 196)
with open("lib/core/storage/database_health_metrics.dart", "w", encoding="utf-8") as f:
    f.write("""/// مقاييس حقيقية لسلامة قاعدة البيانات
class DatabaseHealthMetrics {
  final bool isIntegrityOk;
  final int schemaVersion;
  final int freeSpaceBytes;
  final int walSizeEstimate;

  const DatabaseHealthMetrics({
    required this.isIntegrityOk,
    required this.schemaVersion,
    required this.freeSpaceBytes,
    required this.walSizeEstimate,
  });

  bool get isHealthy => isIntegrityOk && schemaVersion > 0;
}
""")

print("🔍 فحص سلامة lib/ على السيرفر السحابي...")
result = subprocess.run(["dart", "analyze", "lib/"], capture_output=True, text=True)

if "No issues found!" in result.stdout:
    print("✅ تم تطبيق الحزمة بنجاح تام:")
    print("   No issues found!")
    os.remove("run_megabatch1.py")
else:
    print("❌ تفاصيل الفحص البرمجي:")
    print(result.stdout)
    sys.exit(1)
