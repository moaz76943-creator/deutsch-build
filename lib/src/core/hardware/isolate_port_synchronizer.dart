class IsolatePortSynchronizer {
  bool isConnected = false;
  void handshake() => isConnected = true;
}
