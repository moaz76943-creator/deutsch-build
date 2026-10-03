import 'dart:async';

import '../domain/sync_services.dart';

/// Infrastructure bridge for platform/network reachability signals.
///
/// The composition root can feed this adapter from an existing platform signal.
/// It intentionally performs no background polling and defaults to offline.
final class ConnectivitySignalBridge implements ConnectivityService {
  ConnectivitySignalBridge({bool initialOnline = false})
      : _online = initialOnline;

  bool _online;
  final StreamController<bool> _changes =
      StreamController<bool>.broadcast(sync: true);

  @override
  Future<bool> isOnline() async => _online;

  @override
  Stream<bool> get changes => _changes.stream;

  void update(bool online) {
    if (_online == online || _changes.isClosed) return;
    _online = online;
    _changes.add(online);
  }

  Future<void> dispose() async {
    await _changes.close();
  }
}
