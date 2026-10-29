import '../architecture/operation_result.dart';

class MissingOfflineVoiceFailure extends OperationFailure {
  const MissingOfflineVoiceFailure() : super('MISSING_VOICE', 'Offline voice not found');
}

class MissingDictionaryFailure extends OperationFailure {
  const MissingDictionaryFailure() : super('MISSING_DICT', 'Optional dictionary not found');
}

class InvalidVaultFailure extends OperationFailure {
  const InvalidVaultFailure() : super('INVALID_VAULT', 'Vault is invalid or corrupted');
}
