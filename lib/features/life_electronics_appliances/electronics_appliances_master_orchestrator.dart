import 'package:flutter/foundation.dart';

import 'electronics_appliances_models.dart';
import 'electronics_appliances_routes.dart';

final class ElectronicsAppliancesMasterOrchestrator extends ChangeNotifier {
  ElectronicsDomain _domain = ElectronicsDomain.all;
  String _query = '';

  ElectronicsDomain get domain => _domain;
  String get query => _query;

  List<ElectronicsRouteDescriptor> get visibleRoutes {
    return List<ElectronicsRouteDescriptor>.unmodifiable(
      ElectronicsAppliancesRoutes.all.where((route) {
        final domainMatches =
            _domain == ElectronicsDomain.all || route.domain == _domain;
        return domainMatches && route.matches(_query);
      }),
    );
  }

  String get guidanceDe =>
      'Technische Daten immer am konkreten Modell prüfen. Garantiebedingungen des Anbieters und gesetzliche Gewährleistungsrechte nicht miteinander verwechseln.';

  String get guidanceAr =>
      'تحقق من المواصفات على الموديل نفسه، ولا تخلط بين ضمان الجهة المقدمة Garantie وحقوق العيوب القانونية Gewährleistung.';

  void setDomain(ElectronicsDomain value) {
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
    if (_domain == ElectronicsDomain.all && _query.isEmpty) return;
    _domain = ElectronicsDomain.all;
    _query = '';
    notifyListeners();
  }
}
