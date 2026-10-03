import 'package:flutter/foundation.dart';

import 'neighborhood_sub_agent.dart';
import 'occasions_sub_agent.dart';
import 'social_models.dart';

final class SocialMasterOrchestrator extends ChangeNotifier {
  SocialMasterOrchestrator({
    NeighborhoodSubAgent neighborhood = const NeighborhoodSubAgent(),
    OccasionsSubAgent occasions = const OccasionsSubAgent(),
  })  : _neighborhood = neighborhood,
        _occasions = occasions;

  final NeighborhoodSubAgent _neighborhood;
  final OccasionsSubAgent _occasions;

  SocialTone _tone = SocialTone.sie;
  SocialCategory _category = SocialCategory.neighborhood;
  String _query = '';

  SocialTone get tone => _tone;
  SocialCategory get category => _category;
  String get query => _query;

  List<String> get quickResponses => switch (_tone) {
        SocialTone.du => const <String>[
            'Danke dir, sehr freundlich.',
            'Kein Problem, gern.',
            'Entschuldige bitte die Umstände.',
          ],
        SocialTone.sie => const <String>[
            'Vielen Dank, das ist sehr freundlich.',
            'Kein Problem, sehr gern.',
            'Entschuldigen Sie bitte die Umstände.',
          ],
      };

  List<SocialPhrase> get visiblePhrases {
    final source = switch (_category) {
      SocialCategory.neighborhood => _neighborhood.phrases,
      SocialCategory.occasions => _occasions.phrases,
    };
    return List<SocialPhrase>.unmodifiable(
      source.where((phrase) => phrase.matches(_query)),
    );
  }

  void setTone(SocialTone value) {
    if (_tone == value) return;
    _tone = value;
    notifyListeners();
  }

  void setCategory(SocialCategory value) {
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
}
