/// Task 1557: Guards peer signed envelopes against packet replay attacks
class AntiReplayWindowVerifier {
  final Set<String> _seenNonces = {};
  bool isFresh(String nonce, int msgTime, int now) {
    if ((now - msgTime).abs() > 60000 || _seenNonces.contains(nonce)) return false;
    _seenNonces.add(nonce);
    return true;
  }
}
