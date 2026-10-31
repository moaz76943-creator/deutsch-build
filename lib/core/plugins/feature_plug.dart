import 'package:flutter/widgets.dart';

abstract class FeaturePlug {
  String get id;
  String get displayName;
  Widget buildEntry(BuildContext context);
}
