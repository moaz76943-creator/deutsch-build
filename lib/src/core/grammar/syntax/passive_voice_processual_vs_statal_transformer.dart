/// Task 1313: Vorgangspassiv (werden) vs Zustandspassiv (sein) transformer
class PassiveVoiceTransformer {
  String getAuxiliary(bool isProcessual) => isProcessual ? 'werden' : 'sein';
}
