/// Task 1694: Anchors conversational avatar speech to 3D portal coordinates
class AvatarAudioAnchor {
  Map<String, double> getAudioSourcePosition(double doorX, double doorY, double doorZ) => {'x': doorX, 'y': doorY + 1.6, 'z': doorZ};
}
