import 'package:flutter/foundation.dart';

import 'public_office_models.dart';
import 'public_office_routes.dart';

final class PublicOfficesMasterOrchestrator extends ChangeNotifier {
  PublicOfficesMasterOrchestrator({
    Iterable<PublicOfficeModuleDependency> dependencies =
        const <PublicOfficeModuleDependency>[],
    Iterable<OfficialAppointment> appointments =
        const <OfficialAppointment>[],
  })  : _dependencies =
            List<PublicOfficeModuleDependency>.unmodifiable(dependencies),
        _appointments = List<OfficialAppointment>.unmodifiable(appointments);

  final List<PublicOfficeModuleDependency> _dependencies;
  final List<OfficialAppointment> _appointments;

  PublicOfficeType _office = PublicOfficeType.all;
  String _query = '';

  PublicOfficeType get office => _office;
  String get query => _query;

  List<PublicOfficeRouteDescriptor> get visibleRoutes {
    return List<PublicOfficeRouteDescriptor>.unmodifiable(
      PublicOfficeRoutes.all.where(
        (route) => route.supportsOffice(_office) && route.matches(_query),
      ),
    );
  }

  List<OfficialDocument> get documents {
    return List<OfficialDocument>.unmodifiable(
      _dependencies
          .expand((dependency) => dependency.documents)
          .where((document) => document.matchesOffice(_office)),
    );
  }

  List<OfficialAppointment> get appointments {
    if (_office == PublicOfficeType.all) return _appointments;
    return List<OfficialAppointment>.unmodifiable(
      _appointments.where((appointment) => appointment.office == _office),
    );
  }

  PublicOfficeModuleDependency? dependencyFor(PublicOfficeRouteId id) {
    for (final dependency in _dependencies) {
      if (dependency.route.id == id) return dependency;
    }
    return null;
  }

  void setOffice(PublicOfficeType value) {
    if (_office == value) return;
    _office = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearFilters() {
    if (_office == PublicOfficeType.all && _query.isEmpty) return;
    _office = PublicOfficeType.all;
    _query = '';
    notifyListeners();
  }
}
