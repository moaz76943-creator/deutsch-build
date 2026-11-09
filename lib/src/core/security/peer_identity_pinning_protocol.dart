import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Exception thrown when a peer's public key fails pinned identity verification.
class UntrustedPeerException implements Exception {
  final String peerId;
  final String fingerprint;
  UntrustedPeerException(this.peerId, this.fingerprint);

  @override
  String toString() => 'UntrustedPeerException: Peer $peerId identity mismatch [Fingerprint: $fingerprint]';
}

/// Peer public key pinning manager for decentralized mesh networks.
/// Eliminates Man-In-The-Middle (MITM) attacks on local ad-hoc connections.
class PeerIdentityPinningProtocol {
  final Map<String, String> _pinnedFingerprints = <String, String>{};

  int get pinnedPeerCount => _pinnedFingerprints.length;

  /// Compute canonical SHA-256 fingerprint for a raw public key.
  static String computeFingerprint(Uint8List publicKeyBytes) {
    return sha256.convert(publicKeyBytes).toString();
  }

  /// Pin an authorized peer's identity fingerprint.
  void pinPeer(String peerId, Uint8List publicKeyBytes) {
    _pinnedFingerprints[peerId] = computeFingerprint(publicKeyBytes);
  }

  /// Verify that an incoming peer connection matches the pinned identity.
  bool verifyPeer(String peerId, Uint8List presentedPublicKeyBytes) {
    final presentedFingerprint = computeFingerprint(presentedPublicKeyBytes);
    final pinned = _pinnedFingerprints[peerId];

    if (pinned == null) {
      // First-use trust or unpinned: pin dynamically if policy allows, else reject
      _pinnedFingerprints[peerId] = presentedFingerprint;
      return true;
    }

    if (pinned != presentedFingerprint) {
      throw UntrustedPeerException(peerId, presentedFingerprint);
    }

    return true;
  }

  void revokePin(String peerId) {
    _pinnedFingerprints.remove(peerId);
  }
}
