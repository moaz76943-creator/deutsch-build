class InflectionalMorphologyParadigmExpander {
  List<String> conjugatePast(String root, List<String> suffixes) =>
      suffixes.map((s) => '$root$s').toList();
}
