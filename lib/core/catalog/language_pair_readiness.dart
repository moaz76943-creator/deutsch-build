enum PairReadinessState {
  usable,
  unsupported,
  reflexive,
  registered,
  verified,
  installed
}

abstract class DirectedPairReadiness {
  final PairReadinessState state;
  const DirectedPairReadiness(this.state);
}

class ReadinessUsable extends DirectedPairReadiness {
  const ReadinessUsable() : super(PairReadinessState.usable);
}

abstract class ReadinessUnavailable extends DirectedPairReadiness {
  final String reason;
  const ReadinessUnavailable(super.state, this.reason);
}

class ReadinessUnsupported extends ReadinessUnavailable {
  const ReadinessUnsupported(String reason)
      : super(PairReadinessState.unsupported, reason);
}

class ReadinessReflexive extends ReadinessUnavailable {
  const ReadinessReflexive()
      : super(PairReadinessState.reflexive, 'Source and target languages cannot be identical.');
}

class ReadinessRegistered extends ReadinessUnavailable {
  const ReadinessRegistered(String reason)
      : super(PairReadinessState.registered, reason);
}

class ReadinessVerified extends ReadinessUnavailable {
  const ReadinessVerified(String reason)
      : super(PairReadinessState.verified, reason);
}

class ReadinessInstalled extends ReadinessUnavailable {
  const ReadinessInstalled(String reason)
      : super(PairReadinessState.installed, reason);
}
