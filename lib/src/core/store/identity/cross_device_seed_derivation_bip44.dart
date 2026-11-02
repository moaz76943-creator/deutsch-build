class CrossDeviceSeedDerivationBip44 {
  String getDerivationPath(int accountIndex) => "m/44'/9999'/$accountIndex'/0/0";
}
