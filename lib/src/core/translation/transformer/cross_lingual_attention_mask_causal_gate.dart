/// Task 1735: Causal autoregressive attention mask generator
class CausalAttentionMaskGate {
  bool isMasked(int queryIdx, int keyIdx) => keyIdx > queryIdx;
}
