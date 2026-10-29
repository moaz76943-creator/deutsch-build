sealed class RecoveryOutcome {
  const RecoveryOutcome();
}

class RecoverySuccess extends RecoveryOutcome {
  const RecoverySuccess();
}

class RecoveryFailed extends RecoveryOutcome {
  final Object error;
  const RecoveryFailed(this.error);
}

class RecoveryCancelled extends RecoveryOutcome {
  const RecoveryCancelled();
}
