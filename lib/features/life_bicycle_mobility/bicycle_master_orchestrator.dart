import 'package:flutter/foundation.dart';

import 'bicycle_models.dart';
import 'bicycle_routes.dart';

final class BicycleMasterOrchestrator extends ChangeNotifier {
  BicycleDomain _domain = BicycleDomain.all;
  String _query = '';

  BicycleDomain get domain => _domain;
  String get query => _query;

  List<BicycleRouteDescriptor> get visibleRoutes {
    return List<BicycleRouteDescriptor>.unmodifiable(
      BicycleRoutes.all.where((route) {
        final domainMatches =
            _domain == BicycleDomain.all || route.domain == _domain;
        return domainMatches && route.matches(_query);
      }),
    );
  }

  String get safetyNoteDe =>
      'Verkehrszeichen, lokale Führungen und aktuelle Regeln vor Ort beachten. Bei Unsicherheit defensiv fahren und die zuständige Verkehrsregelung prüfen.';

  String get safetyNoteAr =>
      'انتبه دائمًا للإشارات والمسارات المحلية والقواعد الحالية. عند الشك قد بحذر وتحقق من التنظيم المروري المعمول به.';

  void setDomain(BicycleDomain value) {
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
    if (_domain == BicycleDomain.all && _query.isEmpty) return;
    _domain = BicycleDomain.all;
    _query = '';
    notifyListeners();
  }
}
