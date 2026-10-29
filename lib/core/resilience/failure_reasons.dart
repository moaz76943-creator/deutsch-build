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
  const MissingOfflineVoiceFailure([String message = 'Offline voice is missing']) : super(message);
}

class MissingDictionaryFailure extends OptionalFeatureFailure {
  const MissingDictionaryFailure([String message = 'Dictionary is missing']) : super(message);
}

abstract class CriticalIntegrityFailure extends FeatureFailure {
  const CriticalIntegrityFailure(super.message);
}

class InvalidVaultFailure extends CriticalIntegrityFailure {
  const InvalidVaultFailure([String message = 'Invalid vault detected']) : super(message);
}

class StorageIntegrityFailure extends CriticalIntegrityFailure {
  const StorageIntegrityFailure([String message = 'Storage integrity compromised']) : super(message);
}
