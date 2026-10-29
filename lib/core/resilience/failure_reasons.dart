abstract class FeatureFailure implements Exception {
  final String message;
  const FeatureFailure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

abstract class OptionalFeatureFailure extends FeatureFailure {
  const OptionalFeatureFailure(super.message);
}

class MissingOfflineVoiceFailure extends OptionalFeatureFailure {
  const MissingOfflineVoiceFailure(
      [super.message = 'Offline voice is missing']);
}

class MissingDictionaryFailure extends OptionalFeatureFailure {
  const MissingDictionaryFailure([super.message = 'Dictionary is missing']);
}

abstract class CriticalIntegrityFailure extends FeatureFailure {
  const CriticalIntegrityFailure(super.message);
}

class InvalidVaultFailure extends CriticalIntegrityFailure {
  const InvalidVaultFailure([super.message = 'Invalid vault detected']);
}

class StorageIntegrityFailure extends CriticalIntegrityFailure {
  const StorageIntegrityFailure(
      [super.message = 'Storage integrity compromised']);
}
