enum FeatureStatus { disabled, available, ready, unsupported }

/// سجل مركزي للقدرات التعليمية يمنع عرض ميزات غير محملة محلياً
class FeatureCapabilityRegistry {
  FeatureCapabilityRegistry._();
  static final FeatureCapabilityRegistry instance =
      FeatureCapabilityRegistry._();

  final Map<String, FeatureStatus> _features = {};

  void registerFeature(String featureId, FeatureStatus status) {
    _features[featureId] = status;
  }

  FeatureStatus getStatus(String featureId) {
    return _features[featureId] ?? FeatureStatus.unsupported;
  }

  bool isFeatureReady(String featureId) {
    return getStatus(featureId) == FeatureStatus.ready;
  }
}
