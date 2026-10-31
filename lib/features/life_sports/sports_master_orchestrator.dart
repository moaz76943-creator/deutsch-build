import 'package:flutter/foundation.dart';

import 'community_club_sub_agent.dart';
import 'gym_fitness_sub_agent.dart';
import 'sports_models.dart';

final class SportsMasterOrchestrator extends ChangeNotifier {
  SportsMasterOrchestrator({
    GymFitnessSubAgent gymAgent = const GymFitnessSubAgent(),
    CommunityClubSubAgent clubAgent = const CommunityClubSubAgent(),
  })  : _gymAgent = gymAgent,
        _clubAgent = clubAgent;

  final GymFitnessSubAgent _gymAgent;
  final CommunityClubSubAgent _clubAgent;

  SportsFacilityType _facility = SportsFacilityType.all;
  SportsLevel? _level;
  String _query = '';
  bool _pauseExpanded = false;

  SportsFacilityType get facility => _facility;
  SportsLevel? get level => _level;
  String get query => _query;
  bool get pauseExpanded => _pauseExpanded;

  String get membershipPauseGerman =>
      'Ich möchte meine Mitgliedschaft vorübergehend pausieren. '
      'Welche Ruhezeit ist laut meinem Vertrag möglich?';

  String get membershipPauseArabic =>
      'أريد إيقاف عضويتي مؤقتًا. ما مدة التجميد المتاحة وفق عقدي؟';

  String get membershipPauseNoteGerman =>
      'Ruhezeiten, Nachweise und Gebühren richten sich nach dem jeweiligen Vertrag.';

  String get membershipPauseNoteArabic =>
      'مدة التجميد والمستندات والرسوم تعتمد على عقد النادي نفسه.';

  List<SportsPhrase> get allPhrases => List<SportsPhrase>.unmodifiable(
        <SportsPhrase>[
          ..._gymAgent.phrases,
          ..._clubAgent.phrases,
        ],
      );

  List<SportsPhrase> get visiblePhrases {
    final normalizedQuery = _normalize(_query);
    final result = allPhrases.where((item) {
      final facilityMatches = _facility == SportsFacilityType.all ||
          item.facility == _facility;
      final levelMatches = _level == null || item.level == _level;
      final queryMatches = normalizedQuery.isEmpty ||
          _normalize(item.searchableText).contains(normalizedQuery);

      return facilityMatches && levelMatches && queryMatches;
    }).toList(growable: false);

    return List<SportsPhrase>.unmodifiable(result);
  }

  void setFacility(SportsFacilityType value) {
    if (_facility == value) return;
    _facility = value;
    notifyListeners();
  }

  void setLevel(SportsLevel? value) {
    if (_level == value) return;
    _level = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearFilters() {
    final alreadyClear = _facility == SportsFacilityType.all &&
        _level == null &&
        _query.isEmpty;
    if (alreadyClear) return;

    _facility = SportsFacilityType.all;
    _level = null;
    _query = '';
    notifyListeners();
  }

  void togglePauseDetails() {
    _pauseExpanded = !_pauseExpanded;
    notifyListeners();
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss')
        .replaceAll('ـ', '');
  }
}
