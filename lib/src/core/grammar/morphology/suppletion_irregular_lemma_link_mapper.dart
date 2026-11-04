/// Task 1336: Suppletion mapping linking disparate roots (gut/besser, sein/war)
class SuppletionLemmaMapper {
  String getRootLemma(String form) => (form == 'besser' || form == 'best') ? 'gut' : (form == 'war' ? 'sein' : form);
}
