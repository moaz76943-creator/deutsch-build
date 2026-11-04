enum RhythmTimingType { stressTimed, syllableTimed, moraTimed }
class SyllableMoraicTimingIsochronyClassifier {
  final Map<String, RhythmTimingType> langRhythm = {'ar': RhythmTimingType.syllableTimed, 'de': RhythmTimingType.stressTimed};
}
