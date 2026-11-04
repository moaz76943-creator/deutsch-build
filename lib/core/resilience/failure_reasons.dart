import '../architecture/operation_result.dart';

class MissingOfflineVoiceFailure extends OperationFailure {
  const MissingOfflineVoiceFailure()
      : super('MISSING_VOICE', 'Offline voice not found');
}

class MissingDictionaryFailure extends OperationFailure {
  const MissingDictionaryFailure()
      : super('MISSING_DICT', 'Optional dictionary not found');
}

abstract class CriticalIntegrityFailure extends StorageFailure {
  const CriticalIntegrityFailure(super.code, super.message);
}

class InvalidVaultFailure extends CriticalIntegrityFailure {
  const InvalidVaultFailure([String message = 'Vault is invalid or corrupted'])
      : super('INVALID_VAULT', message);
}

class StorageIntegrityFailure extends CriticalIntegrityFailure {
  const StorageIntegrityFailure(
      [String message = 'Storage integrity compromised'])
      : super('STORAGE_INTEGRITY', message);
}
