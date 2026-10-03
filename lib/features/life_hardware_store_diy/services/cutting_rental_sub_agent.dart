import '../../life_diy/diy_models.dart';
import 'cutting_rental_bank.dart';

final class CuttingRentalSubAgent {
  const CuttingRentalSubAgent();

  List<DiyPhrase> get phrases =>
      List<DiyPhrase>.unmodifiable(CuttingRentalBank.phrases);

  List<String> get rentalChecklistDe => const <String>[
        'Kaution und Zahlungsart bestätigen',
        'Zustand des Geräts bei Übernahme dokumentieren',
        'Rückgabezeit und Rückgabestelle bestätigen',
        'Zubehör und enthaltene Teile gemeinsam prüfen',
      ];

  DiyPhrase? byId(String id) {
    for (final phrase in CuttingRentalBank.phrases) {
      if (phrase.id == id) return phrase;
    }
    return null;
  }

  List<DiyPhrase> search(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return phrases;

    return CuttingRentalBank.phrases
        .where((phrase) => phrase.matches(needle))
        .toList(growable: false);
  }
}
