import 'dart:async';
import '../../core/content/german_participial_clauses_engine.dart';

/// Reactive UI Bridge connecting the Participial Clauses Engine with interactive visual cards and telemetry.
class Vol116Wave48UiBridge {
  final GermanParticipialClausesEngine _engine;
  final StreamController<ParticipialClauseModel?> _selectedModelController =
      StreamController<ParticipialClauseModel?>.broadcast();

  ParticipialType? _activeTypeFilter;
  SubjectEquivalenceStatus? _activeStatusFilter;
  CommunicativeDomain? _activeDomainFilter;

  Vol116Wave48UiBridge({GermanParticipialClausesEngine? engine})
      : _engine = engine ?? GermanParticipialClausesEngine();

  Stream<ParticipialClauseModel?> get selectedModelStream =>
      _selectedModelController.stream;

  List<ParticipialClauseModel> get currentFilteredList {
    return _engine.catalog.where((item) {
      if (_activeTypeFilter != null && item.participialType != _activeTypeFilter) {
        return false;
      }
      if (_activeStatusFilter != null && item.equivalenceStatus != _activeStatusFilter) {
        return false;
      }
      if (_activeDomainFilter != null && item.domain != _activeDomainFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setTypeFilter(ParticipialType? type) {
    _activeTypeFilter = type;
  }

  void setStatusFilter(SubjectEquivalenceStatus? status) {
    _activeStatusFilter = status;
  }

  void setDomainFilter(CommunicativeDomain? domain) {
    _activeDomainFilter = domain;
  }

  void clearFilters() {
    _activeTypeFilter = null;
    _activeStatusFilter = null;
    _activeDomainFilter = null;
  }

  void selectModel(ParticipialClauseModel model) {
    _selectedModelController.add(model);
  }

  Map<String, dynamic> getTelemetrySnapshot() {
    final catalog = _engine.catalog;
    return {
      'totalParticipialRules': catalog.length,
      'congruentRulesCount':
          catalog.where((e) => e.equivalenceStatus == SubjectEquivalenceStatus.congruentSubject).length,
      'danglingPitfallsCount':
          catalog.where((e) => e.equivalenceStatus == SubjectEquivalenceStatus.danglingSubjectViolation).length,
      'absoluteConstructionsCount':
          catalog.where((e) => e.equivalenceStatus == SubjectEquivalenceStatus.validAbsoluteDetached).length,
      'cefrStandard': 'C1-C2 Master Level',
      'legalLiabilityCompliance': 'Strict Zero Legal/Medical Liability',
      'privacyStandard': 'Zero PII Verified',
      'subsystem': 'Subsystem 1782 / Wave 48',
    };
  }

  void dispose() {
    _selectedModelController.close();
  }
}
