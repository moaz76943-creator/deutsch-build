/// Task 1375: Tags German modal particles (ja, doch, mal, wohl, eben)
class ModalParticleTagger {
  bool isModalParticle(String token) => ['ja', 'doch', 'mal', 'wohl', 'eben'].contains(token.toLowerCase());
}
