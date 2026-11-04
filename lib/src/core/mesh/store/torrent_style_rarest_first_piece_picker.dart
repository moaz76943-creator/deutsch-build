/// Task 1583: Rarest-first piece picker for distributed swarm download
class RarestFirstPiecePicker {
  int pickRarestPiece(Map<int, int> pieceFrequencies) => pieceFrequencies.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
}
