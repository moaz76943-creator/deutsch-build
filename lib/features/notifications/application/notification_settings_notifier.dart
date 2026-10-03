import 'dart:async';

import '../domain/notification_contracts.dart';
import '../domain/notification_models.dart';

final class NotificationSettingsState {
  const NotificationSettingsState({
    required this.preference,
    this.isSaving = false,
  });

  final NotificationPreference preference;
  final bool isSaving;

  NotificationSettingsState copyWith({
    NotificationPreference? preference,
    bool? isSaving,
  }) {
    return NotificationSettingsState(
      preference: preference ?? this.preference,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final class NotificationSettingsNotifier {
  NotificationSettingsNotifier(this._repository)
      : _state = const NotificationSettingsState(
          preference: NotificationPreference(),
        );

  final NotificationRepository _repository;
  final StreamController<NotificationSettingsState> _changes =
      StreamController<NotificationSettingsState>.broadcast();

  NotificationSettingsState _state;
  bool _disposed = false;

  NotificationSettingsState get state => _state;
  Stream<NotificationSettingsState> get changes => _changes.stream;

  Future<NotificationSettingsState> initialize() async {
    _ensureActive();
    final preference = await _repository.loadPreference();
    _emit(NotificationSettingsState(preference: preference));
    return _state;
  }

  Future<void> setDailyReminderEnabled(bool enabled) {
    return _persist(
      _state.preference.copyWith(dailyReminderEnabled: enabled),
    );
  }

  Future<void> setStreakAlertEnabled(bool enabled) {
    return _persist(
      _state.preference.copyWith(streakAlertEnabled: enabled),
    );
  }

  Future<void> setReminderMinutes(int minutes) {
    return _persist(
      _state.preference.copyWith(preferredReminderMinutes: minutes),
    );
  }

  Future<void> setTone(NotificationTone tone) {
    return _persist(_state.preference.copyWith(tone: tone));
  }

  Future<void> _persist(NotificationPreference next) async {
    _ensureActive();
    final previous = _state.preference;
    _emit(NotificationSettingsState(
      preference: next,
      isSaving: true,
    ));
    try {
      await _repository.savePreference(next);
      _emit(NotificationSettingsState(preference: next));
    } catch (_) {
      _emit(NotificationSettingsState(preference: previous));
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _changes.close();
  }

  void _emit(NotificationSettingsState next) {
    _state = next;
    if (!_changes.isClosed) _changes.add(next);
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('NotificationSettingsNotifier is disposed');
    }
  }
}
