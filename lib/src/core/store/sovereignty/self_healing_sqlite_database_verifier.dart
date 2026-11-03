class SelfHealingSqliteDatabaseVerifier {
  String buildIntegrityCheckSql() => 'PRAGMA integrity_check;';
  String buildRecoverSql() => 'PRAGMA quick_check;';
}
