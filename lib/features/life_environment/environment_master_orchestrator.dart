import 'package:flutter/foundation.dart';

import 'environment_models.dart';
import 'gardening_balcony_sub_agent.dart';
import 'weather_alerts_sub_agent.dart';

final class EnvironmentMasterOrchestrator extends ChangeNotifier {
  EnvironmentMasterOrchestrator({
    WeatherAlertsSubAgent weatherAlerts = const WeatherAlertsSubAgent(),
    GardeningBalconySubAgent gardening = const GardeningBalconySubAgent(),
  })  : _weatherAlerts = weatherAlerts,
        _gardening = gardening;

  final WeatherAlertsSubAgent _weatherAlerts;
  final GardeningBalconySubAgent _gardening;

  EnvironmentCategory _category = EnvironmentCategory.severeWeather;
  String _query = '';
  EnvironmentUrgentAlert? _activeUrgentAlert;

  EnvironmentCategory get category => _category;
  String get query => _query;
  EnvironmentUrgentAlert? get activeUrgentAlert => _activeUrgentAlert;

  List<EnvironmentUrgentAlert> get urgentAlerts => const <EnvironmentUrgentAlert>[
        EnvironmentUrgentAlert(
          kind: UrgentWeatherKind.unwetter,
          titleDe: 'Unwetter',
          titleAr: 'طقس خطير',
          scriptDe:
              'Es gibt eine Unwetterwarnung. Wo finde ich die aktuelle amtliche Warnlage für meine Region?',
          scriptAr:
              'هناك تحذير من طقس خطير. أين أجد أحدث التحذيرات الرسمية لمنطقتي؟',
        ),
        EnvironmentUrgentAlert(
          kind: UrgentWeatherKind.glaette,
          titleDe: 'Glättegefahr',
          titleAr: 'خطر الانزلاق',
          scriptDe:
              'Es besteht Glättegefahr. Welche Wege sollte ich meiden, und ist der öffentliche Verkehr betroffen?',
          scriptAr:
              'هناك خطر انزلاق بسبب الجليد. ما الطرق التي ينبغي تجنبها، وهل تأثرت المواصلات العامة؟',
        ),
      ];

  List<EnvironmentEntry> get visibleEntries {
    final source = switch (_category) {
      EnvironmentCategory.severeWeather => _weatherAlerts.entries,
      EnvironmentCategory.gardeningBalcony => _gardening.entries,
    };
    return List<EnvironmentEntry>.unmodifiable(
      source.where((entry) => entry.matches(_query)),
    );
  }

  void setCategory(EnvironmentCategory value) {
    if (_category == value) return;
    _category = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  void selectUrgentAlert(UrgentWeatherKind kind) {
    final selected = urgentAlerts.firstWhere((alert) => alert.kind == kind);
    if (_activeUrgentAlert?.kind == selected.kind) return;
    _activeUrgentAlert = selected;
    notifyListeners();
  }

  void clearUrgentAlert() {
    if (_activeUrgentAlert == null) return;
    _activeUrgentAlert = null;
    notifyListeners();
  }
}
