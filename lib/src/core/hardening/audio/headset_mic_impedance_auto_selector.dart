/// Task 1056: Auto-selector between built-in mic and external headset mic
class HeadsetMicSelector {
  String selectedInput = 'BUILTIN_MIC';
  void onHeadsetAttached(bool attached) => selectedInput = attached ? 'WIRED_HEADSET_MIC' : 'BUILTIN_MIC';
}
