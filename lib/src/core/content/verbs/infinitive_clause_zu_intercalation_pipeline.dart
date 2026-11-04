/// Task 2076: Intercalates 'zu' between separable prefix and verb stem (e.g. anzufangen)
class InfinitiveZuIntercalationPipeline {
  String intercalateZu(String prefix, String stem) => '$prefix' 'zu' '$stem';
}
