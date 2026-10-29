import 'preposition_models.dart';

abstract interface class PrepositionsRepository {
  List<PrepositionItem> allPrepositions();

  PrepositionItem? byId(String id);

  List<PrepositionChallenge> challenges({
    PrepositionType? type,
    String? level,
  });
}
