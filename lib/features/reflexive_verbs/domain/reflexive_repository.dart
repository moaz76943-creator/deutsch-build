import 'reflexive_models.dart';

abstract interface class ReflexiveRepository {
  List<ReflexiveDrillItem> get allDrills;

  List<ReflexiveDrillItem> forCase(ReflexiveCase reflexCase);

  ReflexiveDrillItem? byId(String id);

  bool isCorrectPronoun(
    ReflexiveDrillItem item,
    String candidate,
  );

  bool isCorrectCase(
    ReflexiveDrillItem item,
    ReflexiveCase candidate,
  );

  String? expectedPronoun({
    required String subjectPronoun,
    required ReflexiveCase reflexCase,
  });

  String normalizePronoun(String value);
}
