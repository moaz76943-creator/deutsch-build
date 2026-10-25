import 'dart:io';

void main() {
  final file = File('lib/services/user_vault_security_service.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
    "throw StateError('Vault key recovery is required before further writes');",
    "throw KeyUnavailableException('Vault key recovery is required before further writes');"
  );

  content = content.replaceAll(
    "Error.throwWithStackTrace(error, trace);",
    "if (error.code == 'vault_key_unavailable_or_corrupt' || error.code.toLowerCase().contains('keystore')) { throw KeyUnavailableException(error.message ?? 'Vault key unavailable'); } else { Error.throwWithStackTrace(error, trace); }"
  );

  content = content.replaceAll(
    "if (error.code == 'vault_key_unavailable_or_corrupt' ||\n        error.code.toLowerCase().contains('keystore')) {\n      UserVaultSecurityService.reportKeyFailure();\n    }\n    if (error.code == 'vault_key_unavailable_or_corrupt' || error.code.toLowerCase().contains('keystore')) { throw KeyUnavailableException(error.message ?? 'Vault key unavailable'); } else { Error.throwWithStackTrace(error, trace); }",
    "if (error.code == 'vault_key_unavailable_or_corrupt' ||\n        error.code.toLowerCase().contains('keystore')) {\n      UserVaultSecurityService.reportKeyFailure();\n      throw KeyUnavailableException(error.message ?? 'Vault key unavailable');\n    }\n    Error.throwWithStackTrace(error, trace);"
  );

  content = content.replaceAll(
    "throw StateError('Invalid encrypted vault envelope');",
    "throw CorruptRecordException('Invalid encrypted vault envelope');"
  );

  content = content.replaceAll(
    "throw StateError('Vault record is corrupt');",
    "throw CorruptRecordException('Vault record is corrupt');"
  );

  content = content.replaceAll(
    "throw StateError('Vault cipher returned an invalid envelope');",
    "throw CorruptRecordException('Vault cipher returned an invalid envelope');"
  );

  content = content.replaceAll(
    "throw StateError('Vault SRS identity mismatch');",
    "throw TamperedRecordException('Vault SRS identity mismatch');"
  );

  content = content.replaceAll(
    "throw StateError('Vault catalog identity mismatch');",
    "throw TamperedRecordException('Vault catalog identity mismatch');"
  );

  file.writeAsStringSync(content);
}
