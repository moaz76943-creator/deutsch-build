/// Task 1835: Multiplexes multiple UI listeners onto a single sovereign event channel
class ChannelMultiplexer {
  final List<Function(dynamic)> _listeners = [];
  void addListener(Function(dynamic) l) => _listeners.add(l);
  void broadcast(dynamic msg) { for (var l in _listeners) l(msg); }
}
