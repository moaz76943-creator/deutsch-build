import 'verb_models.dart';

abstract interface class VerbRepository {
  List<VerbItem> get commonVerbs;

  VerbItem? byInfinitive(String infinitive);
}
