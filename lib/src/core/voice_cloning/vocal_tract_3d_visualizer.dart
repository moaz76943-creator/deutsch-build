class Point3D {
  final double x;
  final double y;
  final double z;

  const Point3D(this.x, this.y, this.z);

  Map<String, double> toJson() => {'x': x, 'y': y, 'z': z};
}

class ArticulatoryPose3D {
  final String phonemeSymbol;
  final Point3D tongueTip;
  final Point3D tongueDorsum;
  final Point3D tongueRoot;
  final double lipRoundingRatio; // 0.0 = spread, 1.0 = pursed rounded
  final double velumOpeningRatio; // 0.0 = oral vowel, 1.0 = nasalized
  final bool vocalCordsVibrating;

  const ArticulatoryPose3D({
    required this.phonemeSymbol,
    required this.tongueTip,
    required this.tongueDorsum,
    required this.tongueRoot,
    required this.lipRoundingRatio,
    required this.velumOpeningRatio,
    required this.vocalCordsVibrating,
  });

  Map<String, dynamic> toJson() => {
    'phoneme': phonemeSymbol,
    'tongueTip': tongueTip.toJson(),
    'tongueDorsum': tongueDorsum.toJson(),
    'tongueRoot': tongueRoot.toJson(),
    'lipRoundingRatio': lipRoundingRatio,
    'velumOpeningRatio': velumOpeningRatio,
    'vocalCordsVibrating': vocalCordsVibrating,
  };
}

class VocalTract3dVisualizer {
  static const Map<String, ArticulatoryPose3D> _poses = {
    // German 'ich-Laut' [ç] as in "ich", "Milch" (Palatal fricative)
    'ç': ArticulatoryPose3D(
      phonemeSymbol: '[ç] (ich-Laut)',
      tongueTip: Point3D(0.2, -0.4, 0.0),
      tongueDorsum: Point3D(0.0, 0.8, 0.0), // High arched towards hard palate
      tongueRoot: Point3D(-0.4, -0.2, 0.0),
      lipRoundingRatio: 0.1,
      velumOpeningRatio: 0.0,
      vocalCordsVibrating: false,
    ),
    // German 'ach-Laut' [x] as in "Buch", "Bach" (Velar fricative)
    'x': ArticulatoryPose3D(
      phonemeSymbol: '[x] (ach-Laut)',
      tongueTip: Point3D(0.1, -0.5, 0.0),
      tongueDorsum: Point3D(-0.5, 0.7, 0.0), // Back arched towards soft palate
      tongueRoot: Point3D(-0.6, -0.1, 0.0),
      lipRoundingRatio: 0.2,
      velumOpeningRatio: 0.0,
      vocalCordsVibrating: false,
    ),
    // German 'ü' [y] (Close front rounded vowel)
    'y': ArticulatoryPose3D(
      phonemeSymbol: '[y] (ü)',
      tongueTip: Point3D(0.3, 0.4, 0.0), // High front
      tongueDorsum: Point3D(0.1, 0.6, 0.0),
      tongueRoot: Point3D(-0.3, -0.3, 0.0),
      lipRoundingRatio: 0.95, // High lip protrusion
      velumOpeningRatio: 0.0,
      vocalCordsVibrating: true,
    ),
    // German uvular fricative 'r' [ʁ] (Standard German R)
    'ʁ': ArticulatoryPose3D(
      phonemeSymbol: '[ʁ] (Standard R)',
      tongueTip: Point3D(0.0, -0.6, 0.0), // Resting low
      tongueDorsum: Point3D(-0.6, 0.5, 0.0),
      tongueRoot: Point3D(-0.7, 0.2, 0.0), // Deep uvular constriction
      lipRoundingRatio: 0.2,
      velumOpeningRatio: 0.0,
      vocalCordsVibrating: true,
    ),
  };

  const VocalTract3dVisualizer();

  ArticulatoryPose3D getPose(String phoneme) {
    return _poses[phoneme] ??
        const ArticulatoryPose3D(
          phonemeSymbol: '[ə] (Schwa)',
          tongueTip: Point3D(0.0, 0.0, 0.0),
          tongueDorsum: Point3D(0.0, 0.0, 0.0),
          tongueRoot: Point3D(0.0, 0.0, 0.0),
          lipRoundingRatio: 0.0,
          velumOpeningRatio: 0.0,
          vocalCordsVibrating: true,
        );
  }

  /// Interpolates smooth transition between two phoneme poses for 60fps animation.
  ArticulatoryPose3D interpolatePoses(ArticulatoryPose3D from, ArticulatoryPose3D to, double progress) {
    final t = progress.clamp(0.0, 1.0);
    return ArticulatoryPose3D(
      phonemeSymbol: '${from.phonemeSymbol} -> ${to.phonemeSymbol}',
      tongueTip: Point3D(
        from.tongueTip.x + (to.tongueTip.x - from.tongueTip.x) * t,
        from.tongueTip.y + (to.tongueTip.y - from.tongueTip.y) * t,
        from.tongueTip.z + (to.tongueTip.z - from.tongueTip.z) * t,
      ),
      tongueDorsum: Point3D(
        from.tongueDorsum.x + (to.tongueDorsum.x - from.tongueDorsum.x) * t,
        from.tongueDorsum.y + (to.tongueDorsum.y - from.tongueDorsum.y) * t,
        from.tongueDorsum.z + (to.tongueDorsum.z - from.tongueDorsum.z) * t,
      ),
      tongueRoot: Point3D(
        from.tongueRoot.x + (to.tongueRoot.x - from.tongueRoot.x) * t,
        from.tongueRoot.y + (to.tongueRoot.y - from.tongueRoot.y) * t,
        from.tongueRoot.z + (to.tongueRoot.z - from.tongueRoot.z) * t,
      ),
      lipRoundingRatio: from.lipRoundingRatio + (to.lipRoundingRatio - from.lipRoundingRatio) * t,
      velumOpeningRatio: from.velumOpeningRatio + (to.velumOpeningRatio - from.velumOpeningRatio) * t,
      vocalCordsVibrating: t > 0.5 ? to.vocalCordsVibrating : from.vocalCordsVibrating,
    );
  }
}
