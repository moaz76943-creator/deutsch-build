class SpeechBreathNaturalizer {
  const SpeechBreathNaturalizer();

  String naturalizeScript(String rawGermanText) {
    String text = rawGermanText.trim();
    text = text.replaceAll(RegExp(r',\s+(weil|dass|obwohl|wenn)\b'), ', [breath:soft:120ms] \$1');
    text = text.replaceAll(RegExp(r'\.\s+'), '. [pause:220ms] ');
    text = text.replaceAll(RegExp(r'\?\s+'), '? [pause:260ms] ');
    return text;
  }
}
