import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

/// Service that updates the Android home-screen widget with daily word
/// and pending SRS review count. Fully offline, uses existing local data.
final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService();
});

class HomeWidgetService {
  static const String _androidProvider = 'DeutschWidgetProvider';

  /// Call after any SRS review or vocabulary change.
  Future<void> updateWidget({
    required String word,
    required String translation,
    required int dueCount,
  }) async {
    await HomeWidget.saveWidgetData<String>('daily_word', word);
    await HomeWidget.saveWidgetData<String>('daily_translation', translation);
    await HomeWidget.saveWidgetData<int>('due_count', dueCount);
    await HomeWidget.updateWidget(
      name: _androidProvider,
      androidName: _androidProvider,
    );
  }

  Future<void> clearWidget() async {
    await HomeWidget.saveWidgetData<String>('daily_word', '');
    await HomeWidget.saveWidgetData<String>('daily_translation', '');
    await HomeWidget.saveWidgetData<int>('due_count', 0);
    await HomeWidget.updateWidget(
      name: _androidProvider,
      androidName: _androidProvider,
    );
  }
}
