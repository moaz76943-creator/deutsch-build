import 'package:flutter/foundation.dart';

import '../domain/culture_models.dart';
import 'adult_education_sub_agent.dart';
import 'public_library_sub_agent.dart';

final class CultureMasterOrchestrator extends ChangeNotifier {
  CultureMasterOrchestrator({
    this.libraryAgent = const PublicLibrarySubAgent(),
    this.adultEducationAgent = const AdultEducationSubAgent(),
  });

  final PublicLibrarySubAgent libraryAgent;
  final AdultEducationSubAgent adultEducationAgent;

  CultureDomain _activeDomain = CultureDomain.publicLibrary;
  String _query = '';
  String? _selectedGuideId;

  CultureDomain get activeDomain => _activeDomain;
  String get query => _query;
  CultureGuide get quickCardRenewalGuide => libraryAgent.quickCardRenewalGuide;

  List<CultureGuide> get visibleGuides {
    final normalized = _normalize(_query);
    return List<CultureGuide>.unmodifiable(
      _guidesFor(_activeDomain).where(
        (guide) => guide.matches(normalized),
      ),
    );
  }

  CultureGuide? get activeGuide {
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

  void setDomain(CultureDomain domain) {
    if (_activeDomain == domain && _query.isEmpty && _selectedGuideId == null) {
      return;
    }

    _activeDomain = domain;
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
    final belongsToDomain = _guidesFor(_activeDomain).any(
      (guide) => guide.id == normalizedId,
    );

    if (!belongsToDomain) {
      throw ArgumentError.value(
        guideId,
        'guideId',
        'Guide does not belong to the active culture domain.',
      );
    }

    if (_selectedGuideId == normalizedId) return;
    _selectedGuideId = normalizedId;
    notifyListeners();
  }

  void openQuickCardRenewal() {
    final renewal = quickCardRenewalGuide;
    final changed = _activeDomain != CultureDomain.publicLibrary ||
        _query.isNotEmpty ||
        _selectedGuideId != renewal.id;

    _activeDomain = CultureDomain.publicLibrary;
    _query = '';
    _selectedGuideId = renewal.id;

    if (changed) notifyListeners();
  }

  List<CultureGuide> _guidesFor(CultureDomain domain) => switch (domain) {
        CultureDomain.publicLibrary => libraryAgent.guides,
        CultureDomain.adultEducation => adultEducationAgent.guides,
      };

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
