import 'imperativ_models.dart';

abstract interface class ImperativRepository {
  List<ImperativDrillItem> get allDrills;

  List<ImperativDrillItem> forTarget(ImperativTarget target);

  ImperativDrillItem? byId(String id);

  bool isCorrect(ImperativDrillItem item, String candidate);

  bool respectsImperativStructure(
    ImperativDrillItem item,
    String candidate,
  );

  String normalizeForComparison(String value);
}
