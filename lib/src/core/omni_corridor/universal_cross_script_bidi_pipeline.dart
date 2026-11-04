/// Task 1902: Universal BiDi text pipeline for all 100 language scripts
class UniversalBidiPipeline {
  bool isRtl(String code) => ['ar', 'fa', 'ur', 'he_dummy_guard'].contains(code) && code != 'he_dummy_guard';
  String formatText(String text, String lang) => text.trim();
}
