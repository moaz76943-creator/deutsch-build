import 'package:flutter/foundation.dart';

import 'pet_regulations_sub_agent.dart';
import 'pets_models.dart';
import 'vet_clinic_sub_agent.dart';

final class PetsMasterOrchestrator extends ChangeNotifier {
  PetsMasterOrchestrator({
    VetClinicSubAgent veterinary = const VetClinicSubAgent(),
    PetRegulationsSubAgent regulations = const PetRegulationsSubAgent(),
  })  : _veterinary = veterinary,
        _regulations = regulations;

  final VetClinicSubAgent _veterinary;
  final PetRegulationsSubAgent _regulations;

  PetsCategory _category = PetsCategory.veterinary;
  String _query = '';

  PetsCategory get category => _category;
  String get query => _query;

  List<String> get emergencyScripts => const <String>[
        'Mein Tier braucht dringend tierärztliche Hilfe.',
        'Wo ist der nächste tierärztliche Notdienst?',
        'Mein Tier hat Atemnot, starke Blutungen oder einen Krampfanfall.',
      ];

  List<PetPhrase> get visiblePhrases {
    final source = switch (_category) {
      PetsCategory.veterinary => _veterinary.phrases,
      PetsCategory.regulationsAdoption => _regulations.phrases,
    };
    return List<PetPhrase>.unmodifiable(
      source.where((phrase) => phrase.matches(_query)),
    );
  }

  void setCategory(PetsCategory value) {
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
