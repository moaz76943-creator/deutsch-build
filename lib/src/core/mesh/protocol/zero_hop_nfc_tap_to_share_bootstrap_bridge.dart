/// Task 1518: NFC tap-to-share bootstrap payload initiating Wi-Fi Direct pairing
class NfcBootstrapBridge {
  String generateNfcPayload(String ssid, String passphrase) => 'POLYGLOT_WIFI_DIRECT:$ssid:$passphrase';
}
