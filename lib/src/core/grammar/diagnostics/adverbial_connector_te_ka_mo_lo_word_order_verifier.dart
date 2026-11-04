/// Task 1355: Verifies TeKaMoLo adverbial order (Temporal, Kausal, Modal, Lokal)
class TeKaMoLoOrderVerifier {
  bool isTeKaMoLo(List<String> types) => types.join('_') == 'temporal_kausal_modal_lokal';
}
