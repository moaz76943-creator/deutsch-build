/// Task 1082: FlutterError.onError safe visual fallback view
class FallbackRenderView {
  bool fallbackActive = false;
  void triggerFallback() => fallbackActive = true;
  String get fallbackStatus => fallbackActive ? 'ACTIVE_SAFE_VIEW' : 'NORMAL';
}
