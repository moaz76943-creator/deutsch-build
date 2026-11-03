/// Task 1275: OpenType 'sups'/'subs' optical scaler maintaining stroke weight
class SuperSubScriptScaler {
  double getScale(bool isSuper) => 0.65;
  double getYOffset(bool isSuper, double fontSize) => isSuper ? fontSize * -0.4 : fontSize * 0.2;
}
