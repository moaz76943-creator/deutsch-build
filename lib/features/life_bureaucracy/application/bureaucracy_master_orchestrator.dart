import 'package:flutter/foundation.dart';

import '../domain/bureaucracy_models.dart';
import 'city_registration_sub_agent.dart';
import 'immigration_office_sub_agent.dart';

final class BureaucracyMasterOrchestrator extends ChangeNotifier {
  BureaucracyMasterOrchestrator({
    this.cityAgent = const CityRegistrationSubAgent(),
    this.immigrationAgent = const ImmigrationOfficeSubAgent(),
  });

  final CityRegistrationSubAgent cityAgent;
  final ImmigrationOfficeSubAgent immigrationAgent;

  BureaucracyCategory _activeCategory = BureaucracyCategory.cityRegistration;
  String _query = '';
  String? _selectedGuideId;
  final Set<String> _readyDocumentIds = <String>{};

  BureaucracyCategory get activeCategory => _activeCategory;
  BureaucracyRegister get activeRegister => BureaucracyRegister.formalSie;
  String get query => _query;

  List<BureaucracyGuide> get visibleGuides {
    final normalized = _normalize(_query);
    return List<BureaucracyGuide>.unmodifiable(
      _guidesFor(_activeCategory).where(
        (guide) => guide.matches(normalized),
      ),
    );
  }

  BureaucracyGuide? get activeGuide {
    final visible = visibleGuides;
    if (visible.isEmpty) return null;

    final selectedId = _selectedGuideId;
    if (selectedId != null) {
      for (final guide in visible) {
        if (guide.id == selectedId) return guide;
      }
    }
    return visible.first;
  }

  ChecklistSnapshot get panicChecklist {
    final guide = activeGuide;
    if (guide == null) {
      return ChecklistSnapshot(
        documents: const <OfficialDocument>[],
        readyDocumentIds: const <String>{},
      );
    }

    final guideIds = guide.documents.map((document) => document.id).toSet();
    return ChecklistSnapshot(
      documents: guide.documents,
      readyDocumentIds: _readyDocumentIds.intersection(guideIds),
    );
  }

  void setCategory(BureaucracyCategory category) {
    if (_activeCategory == category && _query.isEmpty) return;

    _activeCategory = category;
    _query = '';
    _selectedGuideId = null;
    notifyListeners();
  }

  void search(String value) {
    final next = value.trim();
    if (_query == next) return;

    _query = next;
    final selected = _selectedGuideId;
    if (selected != null &&
        !visibleGuides.any((guide) => guide.id == selected)) {
      _selectedGuideId = null;
    }
    notifyListeners();
  }

  void clearSearch() => search('');

  void selectGuide(String guideId) {
    final normalizedId = guideId.trim();
    final categoryGuides = _guidesFor(_activeCategory);
    final belongsToCategory =
        categoryGuides.any((guide) => guide.id == normalizedId);

    if (!belongsToCategory) {
      throw ArgumentError.value(
        guideId,
        'guideId',
        'Guide does not belong to the active bureaucracy category.',
      );
    }

    if (_selectedGuideId == normalizedId) return;
    _selectedGuideId = normalizedId;
    notifyListeners();
  }

  void setDocumentReady(String documentId, bool ready) {
    final guide = activeGuide;
    if (guide == null) {
      throw StateError('No active bureaucracy guide.');
    }

    final normalizedId = documentId.trim();
    final belongsToGuide =
        guide.documents.any((document) => document.id == normalizedId);
    if (!belongsToGuide) {
      throw ArgumentError.value(
        documentId,
        'documentId',
        'Document does not belong to the active guide.',
      );
    }

    final changed = ready
        ? _readyDocumentIds.add(normalizedId)
        : _readyDocumentIds.remove(normalizedId);
    if (changed) notifyListeners();
  }

  bool isDocumentReady(String documentId) =>
      _readyDocumentIds.contains(documentId.trim());

  List<BureaucracyGuide> _guidesFor(BureaucracyCategory category) =>
      switch (category) {
        BureaucracyCategory.cityRegistration => cityAgent.guides,
        BureaucracyCategory.immigrationOffice => immigrationAgent.guides,
      };

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
