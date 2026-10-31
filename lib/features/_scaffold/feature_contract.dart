/// عقد موحد لأي ميزة مستقبلية - يضمن العزل التام وعدم كسر النواة
abstract class AppFeatureContract {
  String get featureId;
  bool get isEnabledByDefault => true;
  void initialize();
  void dispose();
}
