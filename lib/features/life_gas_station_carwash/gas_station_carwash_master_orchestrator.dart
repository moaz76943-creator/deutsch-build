import 'package:flutter/foundation.dart';

import 'gas_station_carwash_models.dart';
import 'gas_station_carwash_routes.dart';

final class GasStationCarwashMasterOrchestrator extends ChangeNotifier {
  GasStationDomain _domain = GasStationDomain.all;
  String _query = '';

  GasStationDomain get domain => _domain;
  String get query => _query;

  List<GasStationRouteDescriptor> get visibleRoutes {
    return List<GasStationRouteDescriptor>.unmodifiable(
      GasStationCarwashRoutes.all.where((route) {
        final domainMatches =
            _domain == GasStationDomain.all || route.domain == _domain;
        return domainMatches && route.matches(_query);
      }),
    );
  }

  String get safetyNoteDe =>
      'Beim Kraftstoff immer Fahrzeugfreigabe, Tankdeckelhinweis und Zapfsäulenkennzeichnung prüfen. In Waschanlagen gelten die konkreten Anweisungen der Anlage und des Personals.';

  String get safetyNoteAr =>
      'تحقق دائمًا من نوع الوقود المسموح للسيارة ومن علامة غطاء الخزان والمضخة. وفي المغسلة اتبع تعليمات المنشأة والموظفين حرفيًا.';

  void setDomain(GasStationDomain value) {
    if (_domain == value) return;
    _domain = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearFilters() {
    if (_domain == GasStationDomain.all && _query.isEmpty) return;
    _domain = GasStationDomain.all;
    _query = '';
    notifyListeners();
  }
}
