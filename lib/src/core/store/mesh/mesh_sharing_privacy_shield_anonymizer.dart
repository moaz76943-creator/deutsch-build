class MeshSharingPrivacyShieldAnonymizer {
  String generateEphemeralPeerTag() => 'peer_${DateTime.now().millisecondsSinceEpoch}';
}
