/// Task 1437: Pre-assessment acoustic quality gatekeeper (clipping, SNR)
class AcousticQualityGatekeeper {
  bool isAudioUsable(double snrDb, bool hasClipping) => snrDb >= 12.0 && !hasClipping;
}
