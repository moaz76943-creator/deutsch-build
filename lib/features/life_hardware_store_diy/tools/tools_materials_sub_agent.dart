import '../../life_diy/diy_models.dart';
import 'tools_materials_bank.dart';

final class ToolsMaterialsSubAgent {
  const ToolsMaterialsSubAgent();

  List<DiyPhrase> get phrases =>
      List<DiyPhrase>.unmodifiable(ToolsMaterialsBank.phrases);

  DiyPhrase? byId(String id) {
    for (final phrase in ToolsMaterialsBank.phrases) {
      if (phrase.id == id) return phrase;
    }
    return null;
  }

  List<DiyPhrase> search(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return phrases;

    return ToolsMaterialsBank.phrases
        .where((phrase) => phrase.matches(needle))
        .toList(growable: false);
  }
}
