import 'preferences_service.dart';
import '../core/view_mode.dart';

class UiPreferences {
  static const viewModeKey = 'vocabulary_view_mode';
  final PreferencesService _prefs;

  const UiPreferences(this._prefs);

  ViewMode? get viewMode {
    final stored = _prefs.getString(viewModeKey);
    if (stored == null || stored.isEmpty) return null;
    final normalized = stored.startsWith('ViewMode.')
        ? stored.substring('ViewMode.'.length)
        : stored;
    for (final mode in ViewMode.values) {
      if (mode.name == normalized) return mode;
    }
    return null;
  }

  Future<bool> setViewMode(ViewMode mode) {
    return _prefs.setString(viewModeKey, mode.name);
  }
}
