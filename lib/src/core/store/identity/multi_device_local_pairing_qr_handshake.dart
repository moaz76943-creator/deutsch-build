class MultiDeviceLocalPairingQrHandshake {
  String buildQrPayload(String ephemeralSessionKey) => 'polyglot:sync:$ephemeralSessionKey';
}
