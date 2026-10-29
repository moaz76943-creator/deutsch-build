import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionState {
  final String sessionId;
  final String currentRoute;
  final int lastItemIndex;
  final int timestamp;

  SessionState({
    required this.sessionId,
    required this.currentRoute,
    required this.lastItemIndex,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'session_id': sessionId,
    'current_route': currentRoute,
    'last_item_index': lastItemIndex,
    'timestamp': timestamp,
  };

  factory SessionState.fromMap(Map<String, dynamic> map) => SessionState(
    sessionId: map['session_id'] as String,
    currentRoute: map['current_route'] as String,
    lastItemIndex: map['last_item_index'] as int,
    timestamp: map['timestamp'] as int,
  );
}

class SessionRecoveryManager {
  static const String _storageKey = 'deutsch_active_session_recovery_v1';
  final SharedPreferences _prefs;

  SessionRecoveryManager(this._prefs);

  Future<void> persistSession(SessionState state) async {
    final rawJson = jsonEncode(state.toMap());
    await _prefs.setString(_storageKey, rawJson);
  }

  SessionState? restoreSession() {
    final rawJson = _prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return SessionState.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _prefs.remove(_storageKey);
  }
}
