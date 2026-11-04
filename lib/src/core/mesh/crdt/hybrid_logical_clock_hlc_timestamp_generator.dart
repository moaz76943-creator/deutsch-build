/// Task 1524: Hybrid Logical Clock (HLC) combining physical and logical time
class HybridLogicalClock {
  int l = 0;
  int c = 0;
  void update(int pt, int remoteL, int remoteC) {
    int maxL = [l, pt, remoteL].reduce((a, b) => a > b ? a : b);
    if (maxL == l && maxL == remoteL) c = [c, remoteC].reduce((a, b) => a > b ? a : b) + 1;
    else if (maxL == l) c++;
    else if (maxL == remoteL) c = remoteC + 1;
    else c = 0;
    l = maxL;
  }
}
