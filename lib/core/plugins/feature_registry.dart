import 'package:flutter/widgets.dart';
import 'feature_plug.dart';

class FeatureRegistry {
  FeatureRegistry._internal();
  static final FeatureRegistry instance = FeatureRegistry._internal();

  final Map<String, FeaturePlug> _plugs = {};

  /// تسجيل مقبس جديد تلقائياً
  void register(FeaturePlug plug) {
    _plugs[plug.id] = plug;
  }

  /// إلغاء تسجيل مقبس دون أي تأثير جانبي
  void unregister(String plugId) {
    _plugs.remove(plugId);
  }

  /// الحصول على قائمة جميع الميزات النشطة
  List<FeaturePlug> get activeFeatures => _plugs.values.toList();

  /// تشغيل ميزة عبر معرفها بأمان
  Widget? buildFeature(String plugId, BuildContext context) {
    return _plugs[plugId]?.buildEntry(context);
  }
}
