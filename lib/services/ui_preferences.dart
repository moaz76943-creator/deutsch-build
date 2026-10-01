import 'preferences_service.dart';
import '../core/view_mode.dart';

class UiPreferences {
  static const viewModeKey = 'vocabulary_view_mode';
  final PreferencesService _prefs;

  const UiPreferences(this._prefs);

  ViewMode? get viewMode {
    final modeString = _prefs.getString(viewModeKey);
    if (modeString == 'ViewMode.flashcard') return ViewMode.flashcard;
    if (modeString == 'ViewMode.grid') return ViewMode.grid;
    if (modeString == 'ViewMode.list') return ViewMode.list;
    return null;
  }

  Future<bool> setViewMode(ViewMode mode) {
    return _prefs.setString(viewModeKey, mode.toString());
  }
}
